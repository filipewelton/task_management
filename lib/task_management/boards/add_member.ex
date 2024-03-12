defmodule TaskManagement.Boards.AddMember do
  import Ecto.Changeset, only: [change: 2]

  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Repo, User}
  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.Members.Create, as: CreateMember

  @type payload :: %{
          board_id: String.t(),
          user_id: String.t(),
          role: String.t()
        }

  @spec call(payload(), User) :: tuple()
  def call(payload, executor) do
    board_id = Map.get(payload, :board_id)
    user_id = Map.get(payload, :user_id)
    role = Map.get(payload, :role)

    with {:ok, board} <- GetBoard.by_id(board_id),
         :ok <- check_permission(board, executor),
         :ok <- not_listed(board, user_id),
         {:ok, updated_board} <- update_board(board, user_id, role),
         :ok <- emit_notification(updated_board, executor, user_id) do
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

  defp not_listed(board, user_id) do
    %Board{members: members} = board
    ids = Enum.map(members, & &1.user_id)

    case user_id in ids do
      true -> {:error, "This user is already listed!", 409}
      false -> :ok
    end
  end

  defp update_board(board, user_id, role) do
    Repo.transaction(fn -> handle_transaction(board, user_id, role) end)
  rescue
    exception -> exception.term
  end

  defp handle_transaction(board, user_id, role) do
    %Board{id: board_id, members: members} = board

    {:ok, member} =
      CreateMember.call(%{
        board_id: board_id,
        user_id: user_id,
        role: role
      })

    {:ok, changeset} = Board.build(board, %{})
    changeset = change(changeset, %{members: members ++ [member]})
    {:ok, updated_board} = Repo.update(changeset)

    updated_board
  end

  defp emit_notification(%Board{id: id}, %User{id: executor_id}, user_id) do
    payload = ~s({
      "sender_id": "#{executor_id}",
      "message": "You have been added to the [#{id}] board!",
      "date": "#{DateTime.utc_now()}"
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
