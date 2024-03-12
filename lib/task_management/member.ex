defmodule TaskManagement.Member do
  use Ecto.Schema

  import Ecto.Changeset

  alias TaskManagement.Helpers.HandleChangesetResponse
  alias TaskManagement.{Board, Task, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:id, :role, :user_id]}

  @roles ["owner", "master", "team"]
  @fields [:role]

  schema "members" do
    field :role, :string
    belongs_to :board, Board
    belongs_to :user, User
    many_to_many :tasks, Task, join_through: "task_members"
  end

  def build(values) do
    handle_changeset(%__MODULE__{}, values)
    |> validate_change(:role, &validate_role/2)
    |> HandleChangesetResponse.call()
  end

  def build(struct, values) do
    handle_changeset(struct, values)
    |> validate_change(:role, &validate_role/2)
    |> HandleChangesetResponse.call()
  end

  defp handle_changeset(struct, values) do
    struct
    |> cast(values, @fields)
    |> validate_required(@fields)
  end

  defp validate_role(:role, value) do
    case value in @roles do
      true -> []
      false -> [role: "Invalid member role"]
    end
  end
end
