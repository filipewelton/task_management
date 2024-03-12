defmodule TaskManagement.Task do
  use Ecto.Schema

  import Ecto.Changeset

  alias TaskManagement.Helpers.HandleChangesetResponse
  alias TaskManagement.{Board, Member}
  alias TaskManagement.ChecklistItem

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [:id, :checklist, :description, :deadline, :labels, :title, :status, :members]}

  @creation [:title, :description, :deadline, :labels, :checklist, :status, :board_id]
  @update @creation -- [:board_id]
  @allowed_status ["todo", "doing", "done"]

  schema "tasks" do
    field :checklist, {:array, :map}
    field :description, :string, default: ""
    field :deadline, :date
    field :labels, {:array, :string}
    field :title, :string
    field :status, :string
    belongs_to :board, Board

    many_to_many :members, Member,
      join_through: "task_members",
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  def build(values), do: handle_cast(%__MODULE__{}, values, @creation)

  def build(struct, values), do: handle_cast(struct, values, @update)

  defp handle_cast(struct, values, fields) do
    struct
    |> cast(values, fields)
    |> validate_required(fields)
    |> validate_length(:title, max: 50)
    |> validate_length(:description, max: 150)
    |> validate_change(:labels, &validate_labels/2)
    |> validate_change(:checklist, &validate_checklist/2)
    |> validate_change(:status, &validate_status/2)
    |> HandleChangesetResponse.call()
  end

  defp validate_labels(:labels, labels) do
    regex = ~r/^[a-z]+$/

    case Enum.any?(labels, &(not Regex.match?(regex, &1))) do
      false -> []
      true -> [label: "Has invalid value(s)!"]
    end
  end

  defp validate_checklist(:checklist, checklist) do
    Enum.each(checklist, fn %ChecklistItem{} = item -> item end)
    []
  rescue
    _exception -> [checklist: "Has invalid values!"]
  end

  defp validate_status(:status, status) do
    case status in @allowed_status do
      true -> []
      false -> [status: "Invalid value!"]
    end
  end
end
