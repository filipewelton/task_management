defmodule TaskManagement.Tasks.AddMember do
  import Ecto.Changeset, only: [change: 2]

  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Board, Member, Repo, Task, User}
  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.Members.Get, as: GetMember
  alias TaskManagement.Tasks.Get, as: GetTask

  @type payload :: %{
          task_id: String.t(),
          member_id: String.t()
        }

  @spec call(payload(), User) :: tuple()
  def call(payload, executor) do
    task_id = Map.get(payload, :task_id)
    member_id = Map.get(payload, :member_id)

    with {:ok, task} <- GetTask.by_id(task_id, executor),
         {:ok, member} <- GetMember.by_id(member_id),
         {:ok, board} <- GetBoard.by_id(task.board_id),
         :ok <- check_board_member_list(board, member_id),
         :ok <- check_task_member_list(task, member_id),
         {:ok, updated_task} <- update_task(task, member),
         :ok <- emit_notification(executor, board, member, task_id) do
      {:ok, parse_response(updated_task)}
    end
  end

  defp check_board_member_list(%Board{members: members}, member_id) do
    member = Enum.find(members, &(&1.id == member_id))

    case member do
      %Member{} -> :ok
      nil -> {:error, "This member is not listed on the board!", 409}
    end
  end

  defp check_task_member_list(%Task{members: members}, member_id) do
    member = Enum.find(members, &(&1.id == member_id))

    case member do
      nil -> :ok
      %Member{} -> {:error, "This member already listed in the task!", 409}
    end
  end

  defp update_task(task, member) do
    members = task.members ++ [member]
    {:ok, changeset} = Task.build(task, %{})
    changeset = change(changeset, %{members: members})

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

  defp emit_notification(
         %User{id: executor_id},
         %Board{id: board_id},
         %Member{user_id: user_id},
         task_id
       ) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "You have been added to a task [#{task_id}]!",
      "date": "#{DateTime.utc_now()}"
    })

    Sender.call(board_id, user_id, payload)
  end

  defp parse_response(%Task{id: id, members: members}) do
    %{
      task_id: id,
      members: Enum.map(members, &Map.take(&1, [:id, :role, :user_id, :board_id]))
    }
  end
end
