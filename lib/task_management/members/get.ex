defmodule TaskManagement.Members.Get do
  alias TaskManagement.{Member, Repo}
  alias UUID

  def by_id(id) do
    with {:ok, _} <- UUID.info(id),
         %Member{} = member <- Repo.get(Member, id),
         member <- Repo.preload(member, [:user, :board]) do
      {:ok, member}
    else
      nil -> {:error, "Member not found!", 404}
      {:error, _} -> {:error, "Member id should be a UUID!", 400}
    end
  end

  def by_user_id(id) do
    with {:ok, _} <- UUID.info(id),
         %Member{} = member <- Repo.get_by(Member, user_id: id),
         member <- Repo.preload(member, [:user, :board]) do
      {:ok, member}
    else
      nil -> {:error, "Member not found!", 404}
      {:error, _} -> {:error, "User id should be a UUID!", 400}
    end
  end
end
