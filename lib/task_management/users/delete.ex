defmodule TaskManagement.Users.Delete do
  require Logger

  alias TaskManagement.{Repo, User}

  @spec call(User) :: :ok | tuple()
  def call(user) do
    case Repo.delete(user) do
      {:ok, _} ->
        :ok

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end
end
