defmodule TaskManagement.Tasks.RemoveMember do
  import Ecto.Changeset, only: [change: 2]

  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Member, Repo, Task, User}
  alias TaskManagement.Members.Get, as: GetMember
  alias TaskManagement.Tasks.Get, as: GetTask

  @type args :: %{
          task_id: String.t(),
          member_id: String.t()
        }

  @spec call(args(), User) :: tuple()
  def call(args, executor) do
    task_id = Map.get(args, :task_id)
    member_id = Map.get(args, :member_id)

    with {:ok, task} <- GetTask.by_id(task_id, executor),
         {:ok, member} <- GetMember.by_id(member_id),
         :ok <- task_member?(task, member_id),
         {:ok, updated_task} <- update_task(task, member_id),
         :ok <- emit_notification(executor, task, member) do
      {:ok, parse_response(updated_task)}
    end
  end

  defp task_member?(task, member_id) do
    ids = Enum.map(task.members, & &1.id)

    case member_id in ids do
      true -> :ok
      false -> {:error, "This member is not listed in the task!", 409}
    end
  end

  defp update_task(task, member_id) do
    members = Enum.filter(task.members, &(&1.id != member_id))
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
         %Task{id: task_id, board_id: board_id},
         %Member{user_id: user_id}
       ) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "You have been removed from the task [#{task_id}]!",
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
