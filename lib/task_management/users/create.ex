defmodule TaskManagement.Users.Create do
  alias TaskManagement.{Repo, User}

  @spec call(map()) :: tuple()
  def call(args) do
    with {:ok, changeset} <- User.build(args),
         {:ok, _} = response <- handle_creation(changeset) do
      response
    end
  end

  defp handle_creation(changeset) do
    case Repo.insert(changeset) do
      {:ok, _} = response -> response
      {:error, _} -> {:error, "This user already registered!", 409}
    end
  end
end
