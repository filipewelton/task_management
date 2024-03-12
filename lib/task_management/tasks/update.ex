defmodule TaskManagement.Tasks.Update do
  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Member, Repo, Task, User}
  alias TaskManagement.Tasks.Get

  @spec call(map(), User) :: tuple()
  def call(payload, executor) do
    id = Map.get(payload, :id)

    with {:ok, task} <- Get.by_id(id, executor),
         {:ok, changeset} <- Task.build(task, payload),
         {:ok, task} <- update_task(changeset),
         :ok <- emit_notification(executor, task) do
      {:ok, task}
    end
  end

  defp update_task(changeset) do
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
         %Task{id: task_id, board_id: board_id, members: members}
       ) do
    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "The task [#{task_id}] has been updated!",
      "date": "#{DateTime.utc_now()}"
    })

    for %Member{user_id: user_id} <- members do
      Sender.call(board_id, user_id, payload)
    end

    :ok
  end
end
