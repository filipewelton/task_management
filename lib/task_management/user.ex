defmodule TaskManagement.User do
  use Ecto.Schema
  use Elform

  import Ecto.Changeset

  alias Ecto.Changeset
  alias TaskManagement.Helpers.HandleChangesetResponse
  alias TaskManagement.Member

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @creation [:name, :email, :password]
  @update [:name, :password]
  @derive {Jason.Encoder, only: [:id, :name, :email]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string
    has_many :members, Member, foreign_key: :id
  end

  def build(values), do: handle_changeset(%__MODULE__{}, values, @creation)

  def build(struct, values), do: handle_changeset(struct, values, @update)

  defp handle_changeset(struct, values, fields) do
    struct
    |> cast(values, fields)
    |> validate_required(fields)
    |> unique_constraint(:email)
    |> validate_change(:name, &validate_name/2)
    |> validate_change(:email, &validate_email/2)
    |> validate_change(:password, &validate_password/2)
    |> encrypt_password()
    |> HandleChangesetResponse.call()
  end

  defp validate_name(:name, value) do
    regex = ~r/((^[A-Z][a-z]+)\s)([A-Z][a-z]+\s?|[A-Z]\.\s?)+/

    %{name: name} =
      %{name: required(value) |> matches(regex) |> length_less_than(51)}
      |> Elform.parse_errors()

    case name == :ok do
      true -> []
      false -> [name: name]
    end
  end

  defp validate_password(:password, value) do
    %{password: password} =
      %{password: required(value) |> length_greater_than(11)}
      |> Elform.parse_errors()

    case password == :ok do
      true -> []
      false -> [password: password]
    end
  end

  defp validate_email(:email, value) do
    %{email: email} =
      %{email: required(value) |> email()}
      |> Elform.parse_errors()

    case email == :ok do
      true -> []
      false -> [email: email]
    end
  end

  defp encrypt_password(%Changeset{valid?: true} = changeset) do
    password = Map.get(changeset, :changes) |> Map.get(:password)

    if is_nil(password) do
      changeset
    else
      hash = Bcrypt.hash_pwd_salt(password)
      change(changeset, %{password: hash})
    end
  end

  defp encrypt_password(changeset), do: changeset
end
