defmodule TaskManagementWeb.ErrorJSON do
  alias Ecto.Changeset

  def render("error.json", %{reason: %Changeset{} = reason}) do
    parsed = parse_changeset_error(reason)
    %{error: parsed}
  end

  def render("error.json", %{reason: reason}) do
    %{error: reason}
  end

  defp parse_changeset_error(changeset) do
    {key, {msg, _}} =
      changeset
      |> Map.get(:errors)
      |> List.first()

    substring =
      to_string(key)
      |> String.capitalize()

    substring <> " " <> msg <> "!"
  end
end
