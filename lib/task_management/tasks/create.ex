defmodule TaskManagement.Tasks.Create do
  import Ecto.Changeset, only: [change: 2]

  require Logger

  alias TaskManagement.{Board, Repo, Task, User}
  alias TaskManagement.Boards.Get, as: GetBoard

  @type args :: %{
          board_id: String.t(),
          title: String.t(),
          description: String.t(),
          status: String.t(),
          deadline: Date.t(),
          labels: list(String.t()),
          checklist: list(map())
        }
  @spec call(args(), User) :: {:ok, Task} | {:error, any(), integer()}
  def call(args, executor) do
    board_id = Map.get(args, :board_id)

    with {:ok, board} <- GetBoard.by_id(board_id),
         {:ok, member} <- check_executor_role(board, executor),
         args <- Map.put(args, :board, board),
         {:ok, changeset} <- Task.build(args),
         changeset <- put_member(changeset, member) do
      create_task(changeset)
    end
  end

  defp check_executor_role(%Board{members: members}, %User{id: id}) do
    member = Enum.find(members, %{}, &(&1.user_id == id))

    case Map.get(member, :role) in ["owner", "master"] do
      true -> {:ok, member}
      false -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp put_member(changeset, member) do
    change(changeset, %{members: [member]})
  end

  defp create_task(changeset) do
    case Repo.insert(changeset) do
      {:ok, _} = response ->
        response

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end
end
