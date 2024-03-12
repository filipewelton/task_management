defmodule TaskManagement.Boards.Update do
  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Member, Repo, User}
  alias TaskManagement.Boards.Get

  @type args :: %{
          id: String.t(),
          name: String.t(),
          description: String.t()
        }
  @spec call(args(), User) :: tuple()
  def call(args, executor) do
    id = Map.get(args, :id)

    with {:ok, board} <- Get.by_id(id),
         :ok <- owner?(executor, board),
         {:ok, changeset} <- Board.build(board, args),
         {:ok, updated_board} <- update(changeset),
         :ok <- emit_notification(updated_board, executor) do
      {:ok, updated_board}
    end
  end

  defp owner?(%User{id: id}, %Board{members: members}) do
    %Member{role: role} = Enum.find(members, &(&1.user_id == id))

    case role do
      "owner" -> :ok
      _any -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp update(changeset) do
    case Repo.update(changeset) do
      {:ok, _} = response ->
        response

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, reason, 500}
        # coveralls-ignore-stop
    end
  end

  defp emit_notification(%Board{id: id}, %User{id: executor_id}) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "The [#{id}] board has been updated!",
      "date": "#{NaiveDateTime.utc_now()}"
    })

    Sender.call(id, payload)

    :ok
  end
end
