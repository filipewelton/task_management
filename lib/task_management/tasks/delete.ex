defmodule TaskManagement.Tasks.Delete do
  require Logger

  alias TaskManagement.Services.Notification.Sender
  alias TaskManagement.{Member, Repo, Task, User}
  alias TaskManagement.Tasks.Get, as: GetTask

  @spec call(String.t(), User) :: :ok | tuple()
  def call(id, executor) do
    with {:ok, task} <- GetTask.by_id(id, executor),
         :ok <- delete_task(task) do
      emit_notification(executor, task)
    end
  end

  defp delete_task(task) do
    case Repo.delete(task) do
      {:ok, _} ->
        :ok

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end

  defp emit_notification(%User{id: executor_id}, task) do
    %Task{
      id: task_id,
      members: members,
      board_id: board_id
    } = task

    payload = ~s({
      "executor_id": "#{executor_id}",
      "message": "The task [#{task_id}] has been deleted!",
      "date": "#{DateTime.utc_now()}"
    })

    for %Member{user_id: user_id} <- members do
      Sender.call(board_id, user_id, payload)
    end

    :ok
  end
end
