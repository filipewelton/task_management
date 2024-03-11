defmodule TaskManagement.Services.Notification.Sender do
  alias AMQP.{Basic, BasicError, Channel, Connection, Exchange}

  @uri Application.compile_env!(:task_management, :amqp_uri)

  @spec call(String.t(), String.t()) :: :ok
  def call(board_id, message) do
    with {:ok, connection} <- Connection.open(@uri),
         {:ok, channel} <- Channel.open(connection),
         :ok <- Exchange.declare(channel, board_id, :fanout),
         :ok <- Basic.publish(channel, board_id, "", message),
         :ok <- Connection.close(connection) do
      :ok
    else
      # coveralls-ignore-start
      {:error, reason} ->
        {:error, reason, 500}

      %BasicError{} = reason ->
        {:error, reason, 500}
        # coveralls-ignore-stop
    end
  end

  @spec call(String.t(), String.t(), String.t()) :: :ok
  def call(board_id, user_id, message) do
    exchange = "#{board_id}.membership"

    with {:ok, connection} <- Connection.open(@uri),
         {:ok, channel} <- Channel.open(connection),
         :ok <- Exchange.declare(channel, exchange, :direct),
         :ok <- Basic.publish(channel, exchange, user_id, message),
         :ok <- Connection.close(connection) do
      :ok
    else
      # coveralls-ignore-start
      {:error, reason} ->
        {:error, reason, 500}

      %BasicError{} = reason ->
        {:error, reason, 500}
        # coveralls-ignore-stop
    end
  end
end
