defmodule TaskManagement.Users.Update do
  require Logger

  alias TaskManagement.{Repo, User}

  @spec call(User, map()) :: tuple()
  def call(user, payload) do
    with {:ok, changeset} <- User.build(user, payload),
         {:ok, _} = response <- handle_update(changeset) do
      response
    end
  end

  defp handle_update(changeset) do
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
end
