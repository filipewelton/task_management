defmodule TaskManagement.Users.Get do
  alias TaskManagement.{Repo, User}
  alias UUID

  def by_email(email) when is_bitstring(email) do
    case Repo.get_by(User, email: email) do
      %User{} = user -> {:ok, user}
      nil -> {:error, "User not found!", 404}
    end
  end

  def by_email(email) when is_nil(email) do
    {:error, "User email is required!", 400}
  end

  def by_email(email) when not is_bitstring(email) do
    {:error, "User email must be of type string!", 400}
  end

  def by_id(id) do
    with {:ok, _uuid} <- UUID.info(id),
         %User{} = user <- Repo.get(User, id) do
      {:ok, user}
    else
      {:error, _reason} -> {:error, "User id is invalid!", 400}
      nil -> {:error, "User not found!", 404}
    end
  end
end
