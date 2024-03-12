defmodule TaskManagement.Board do
  use Ecto.Schema
  use Elform

  import Ecto.Changeset

  alias TaskManagement.Helpers.HandleChangesetResponse
  alias TaskManagement.{Member, Task}

  @primary_key {:id, :binary_id, autogenerate: true}
  @fields [:name, :description]
  @derive {Jason.Encoder, only: @fields ++ [:id, :members, :tasks]}

  schema "boards" do
    field :name, :string
    field :description, :string
    has_many :members, Member, on_replace: :delete_if_exists, on_delete: :delete_all
    has_many :tasks, Task, on_replace: :delete_if_exists, on_delete: :delete_all

    timestamps()
  end

  def build(values) do
    %__MODULE__{}
    |> cast(values, @fields)
    |> validate_required(@fields)
    |> validate_change(:name, &validate_name/2)
    |> validate_change(:description, &validate_description/2)
    |> HandleChangesetResponse.call()
  end

  def build(struct, values) do
    changeset = cast(struct, values, @fields)
    name = Map.get(values, :name)
    description = Map.get(values, :description)

    changeset =
      if is_nil(name) do
        changeset
      else
        validate_change(changeset, :name, &validate_name/2)
      end

    changeset =
      if is_nil(description) do
        changeset
      else
        validate_change(changeset, :description, &validate_description/2)
      end

    HandleChangesetResponse.call(changeset)
  end

  defp validate_name(:name, value) do
    %{name: name} =
      %{name: required(value) |> length_less_than(31)}
      |> Elform.parse_errors()

    case name == :ok do
      true -> []
      false -> [name: name]
    end
  end

  defp validate_description(:description, value) do
    %{description: description} =
      %{description: required(value) |> length_less_than(151)}
      |> Elform.parse_errors()

    case description == :ok do
      true -> []
      false -> [description: description]
    end
  end
end
