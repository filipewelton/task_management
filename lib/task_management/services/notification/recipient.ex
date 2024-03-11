defmodule TaskManagement.Services.Notification.Recipient do
  use GenServer
  use AMQP

  require Logger

  @type init_arg :: [boards_id: list(), user_id: String.t(), server_name: atom()]

  @uri Application.compile_env!(:task_management, :amqp_uri)

  @spec start_link(init_arg()) :: GenServer.on_start()
  def start_link(init_arg) do
    server_name = Keyword.get(init_arg, :server_name, __MODULE__)
    GenServer.start(__MODULE__, init_arg, name: server_name)
  end

  @spec stop(atom()) :: :ok
  def stop(server_name \\ __MODULE__), do: GenServer.stop(server_name)

  @spec get_notifications(atom()) :: {:ok, list()}
  def get_notifications(server_name \\ __MODULE__) do
    state = GenServer.call(server_name, :get_state)
    user_id = Keyword.get(state, :user_id)
    user_session = Cachex.get!(:user_sessions, user_id) || []
    notifications_id = Keyword.get(user_session, :notifications, [])

    notifications =
      Enum.map(notifications_id, &Cachex.get!(:notifications, &1))
      |> Enum.filter(&(not is_nil(&1)))

    {:ok, notifications}
  end

  @impl true
  def init(init_arg) do
    boards_id = Keyword.get(init_arg, :boards_id)
    user_id = Keyword.get(init_arg, :user_id)

    {:ok, connection} = Connection.open(@uri)
    {:ok, channel} = Channel.open(connection)

    for bid <- boards_id do
      :ok = Exchange.declare(channel, bid, :fanout)
      {:ok, %{queue: queue}} = Queue.declare(channel, "", exclusive: true)
      :ok = AMQP.Queue.bind(channel, queue, bid)
      {:ok, _} = Basic.consume(channel, queue, nil, no_ack: true)
    end

    exchange = "#{boards_id}.membership"

    :ok = Exchange.declare(channel, exchange, :direct)
    {:ok, %{queue: queue}} = Queue.declare(channel, "", exclusive: true)
    :ok = Queue.bind(channel, queue, exchange, routing_key: user_id)
    {:ok, _} = Basic.consume(channel, queue, nil, no_ack: true)

    {:ok,
     [
       channel: channel,
       connection: connection,
       boards_id: boards_id,
       user_id: user_id
     ]}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info({:basic_consume_ok, _}, state) do
    # coveralls-ignore-next-line
    {:noreply, state}
  end

  # coveralls-ignore-start

  def handle_info({:basic_cancel, _}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:basic_cancel_ok, _}, state) do
    {:noreply, state}
  end

  # coveralls-ignore-stop

  def handle_info({:basic_deliver, raw_payload, _}, state) do
    user_id = Keyword.get(state, :user_id)

    with {:ok, payload} <- decode_message(raw_payload),
         {:ok, _} <- update_cache(user_id, payload) do
      {:noreply, state}
    else
      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:noreply, state}
        # coveralls-ignore-stop
    end
  end

  # coveralls-ignore-start

  @impl true
  def terminate(_reason, state) do
    connection = Keyword.get(state, :connection)
    channel = Keyword.get(state, :channel)

    for id <- Keyword.get(state, :boards_id) do
      Exchange.delete(channel, id)
      Exchange.delete(channel, "#{id}.membership")
    end

    Connection.close(connection)
  end

  # coveralls-ignore-stop

  defp decode_message(raw_payload) do
    payload = Jason.decode!(raw_payload)
    {:ok, Map.take(payload, ["sender_id", "message", "date"])}
  rescue
    # coveralls-ignore-next-line
    _error -> {:error, "Invalid message format."}
  end

  defp update_cache(user_id, payload) do
    user_session = Cachex.get!(:user_sessions, user_id, [default: []]) || []
    user_notifications = Keyword.get(user_session, :notifications, [])
    notification_id = UUID.uuid4()

    updated_user_session =
      Keyword.put(user_session, :notifications, user_notifications ++ [notification_id])

    {:ok, true} = Cachex.put(:notifications, notification_id, payload)
    {:ok, true} = Cachex.put(:user_sessions, user_id, updated_user_session)
  rescue
    # coveralls-ignore-start
    error ->
      Logger.error(error)
      {:error, "Failed to store notification."}
      # coveralls-ignore-stop
  end
end
