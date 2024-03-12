defmodule TaskManagement.Members.Update do
  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Member, Repo, User}
  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.Members.Get, as: GetMember

  @type payload :: %{
          member_id: String.t(),
          board_id: String.t(),
          role: String.t()
        }

  @spec call(payload(), User) :: tuple()
  def call(payload, executor) do
    member_id = Map.get(payload, :member_id)
    board_id = Map.get(payload, :board_id)

    with {:ok, member} <- GetMember.by_id(member_id),
         {:ok, board} <- GetBoard.by_id(board_id),
         :ok <- check_executor_role(executor, board),
         {:ok, changeset} <- Member.build(member, payload),
         {:ok, member} <- update(changeset),
         :ok <- emit_notification(executor, board, member) do
      {:ok, board_id, member}
    end
  end

  defp check_executor_role(%User{id: id}, %Board{members: members}) do
    role =
      Enum.find(members, %{}, &(&1.user_id == id))
      |> Map.get(:role)

    case role in ["owner", "master"] do
      true -> :ok
      false -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp update(changeset) do
    case Repo.update(changeset) do
      {:ok, _} = response ->
        response

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end

  defp emit_notification(%User{id: executor_id}, %Board{id: id}, %Member{user_id: user_id}) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "Its role has been updated on the board [#{id}]!",
      "date": "#{DateTime.utc_now()}"
    })

    Sender.call(id, user_id, payload)
  end
end
