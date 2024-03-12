defmodule TaskManagement.Tasks.Get do
  import Ecto.Query

  alias TaskManagement.{Board, Repo, Task, User}
  alias TaskManagement.Boards.Get, as: GetBoard
  alias UUID

  @spec by_board_id(String.t()) :: tuple()
  def by_board_id(id) do
    query = from task in Task, where: task.board_id == ^id

    UUID.info!(id)

    results =
      Repo.all(query)
      |> Enum.map(&Repo.preload(&1, [:members]))

    {:ok, results}
  rescue
    _error in ArgumentError -> {:error, "Board id should be valid UUID!", 400}
  end

  @spec by_id(String.t(), nil | User) :: tuple()
  def by_id(id, executor) do
    with :ok <- check_id_format(id),
         {:ok, task} <- get_task(id),
         {:ok, board} <- GetBoard.by_id(task.board_id),
         :ok <- check_executor_role(board, executor) do
      {:ok, Repo.preload(task, [:members])}
    end
  end

  defp check_id_format(id) do
    case UUID.info(id) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, "Invalid task id format!", 400}
    end
  end

  defp check_executor_role(_board, nil), do: :ok

  defp check_executor_role(%Board{members: members}, %User{id: id}) do
    role =
      Enum.find(members, %{}, &(&1.user_id == id))
      |> Map.get(:role)

    case role in ["owner", "master"] do
      true -> :ok
      false -> {:error, "You do not have permission for this resource!", 403}
    end
  end

  defp get_task(id) do
    case Repo.get(Task, id) do
      %Task{} = task -> {:ok, task}
      nil -> {:error, "Task not found!", 404}
    end
  end
end
