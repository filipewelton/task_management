defmodule TaskManagement.Helpers.HandleChangesetResponse do
  alias Ecto.Changeset

  def call(%Changeset{valid?: true} = changeset) do
    {:ok, changeset}
  end

  def call(changeset), do: {:error, changeset}
end
