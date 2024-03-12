defmodule TaskManagement.Boards.Delete do
  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Member, Repo, User}
  alias TaskManagement.Boards.Get

  @spec call(String.t(), User) :: :ok | tuple()
  def call(board_id, executor) do
    with {:ok, board} <- Get.by_id(board_id),
         :ok <- owner?(executor, board),
         :ok <- delete_board(board) do
      emit_notification(board, executor)
    end
  end

  defp owner?(%User{id: id}, %Board{members: members}) do
    role = Enum.find(members, %{}, &(&1.user_id == id)) |> Map.get(:role)

    case role do
      "owner" -> :ok
      _any -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp delete_board(%Board{members: members} = board) do
    response =
      Repo.transaction(fn ->
        for member <- members do
          Repo.delete(member)
        end

        Repo.delete(board)
      end)

    case response do
      {:ok, _} ->
        :ok

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end

  defp emit_notification(
         %Board{id: board_id, members: members},
         %User{id: executor_id}
       ) do
    message = ~s({
      "sender_id": "#{executor_id}",
      "message": "The [#{board_id}] board has been deleted!",
      "date": "#{DateTime.utc_now()}"
    })

    for %Member{user_id: id} <- members do
      :ok = Sender.call(board_id, id, message)
    end

    :ok
  rescue
    # coveralls-ignore-start
    error in MatchError ->
      Logger.error(error.term)
      {:error, "Unknown error.", 500}
      # coveralls-ignore-stop
  end
end
