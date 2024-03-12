defmodule TaskManagement.Members.Delete do
  require Logger

  alias TaskManagement.{Member, Repo}
  alias TaskManagement.Members.Get

  def call(id) do
    with {:ok, member} <- Get.by_id(id) do
      case Repo.delete(member) do
        {:ok, %Member{}} ->
          :ok

        # coveralls-ignore-start
        {:error, reason} ->
          Logger.error(reason)
          {:error, "Unknown error.", 500}
          # coveralls-ignore-stop
      end
    end
  end
end
