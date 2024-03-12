defmodule TaskManagement.Boards.RemoveMember do
  import Ecto.Changeset, only: [change: 2]

  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Member, Repo, User}
  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.Members.Delete, as: DeleteMember
  alias TaskManagement.Members.Get, as: GetMember

  @type args :: %{
          board_id: String.t(),
          member_id: String.t()
        }
  @spec call(args(), User) :: tuple()
  def call(args, executor) do
    board_id = Map.get(args, :board_id)
    member_id = Map.get(args, :member_id)

    with {:ok, board} <- GetBoard.by_id(board_id),
         :ok <- check_permission(board, executor),
         {:ok, member} <- GetMember.by_id(member_id),
         :ok <- listed?(board, member_id),
         {:ok, updated_board} <- update_board(board, member_id),
         :ok <- emit_notification(updated_board, executor, member) do
      {:ok, parse_response(updated_board)}
    end
  end

  defp check_permission(%Board{members: members}, %User{id: id}) do
    role =
      Enum.find(members, %{}, &(&1.user_id == id))
      |> Map.get(:role)

    case role in ["owner", "master"] do
      true -> :ok
      false -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp listed?(board, member_id) do
    %Board{members: members} = board
    ids = Enum.map(members, & &1.id)

    case member_id in ids do
      true -> :ok
      false -> {:error, "This member is not listed!", 409}
    end
  end

  defp update_board(board, member_id) do
    members = Enum.filter(board.members, &(&1.id != member_id))

    transact =
      Repo.transaction(fn ->
        :ok = DeleteMember.call(member_id)
        {:ok, changeset} = Board.build(board, %{})
        changeset = change(changeset, %{members: members})
        Repo.update!(changeset)
      end)

    case transact do
      {:ok, board} ->
        {:ok, board}

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-start
    end
  end

  defp emit_notification(%Board{id: id}, %User{id: executor_id}, %Member{user_id: user_id}) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "You have been removed from [#{id}] board!",
      "date": "#{NaiveDateTime.utc_now()}"
    })

    Sender.call(id, user_id, payload)
  end

  defp parse_response(%Board{id: id, members: members}) do
    %{
      board_id: id,
      members: Enum.map(members, &Map.take(&1, [:id, :role, :user_id, :board_id]))
    }
  end
end
