defmodule TaskManagement.Boards.Create do
  use Elform

  import Ecto.Changeset

  require Logger

  alias TaskManagement.{Board, Repo}
  alias TaskManagement.Members.Create, as: CreateMember
  alias TaskManagement.Users.Get, as: GetUser

  @type args :: %{
          name: String.t(),
          description: String.t(),
          user_id: String.t()
        }
  @spec call(args()) :: tuple()
  def call(args) do
    user_id = Map.get(args, :user_id)

    with {:ok, _user} <- GetUser.by_id(user_id),
         {:ok, changeset} <- Board.build(args) do
      transact(changeset, user_id)
    end
  end

  defp transact(changeset, user_id) do
    Repo.transaction(fn ->
      board = Repo.insert!(changeset)

      {:ok, member} =
        CreateMember.call(%{
          board_id: board.id,
          user_id: user_id,
          role: "owner"
        })

      board = Repo.preload(board, [:members])
      {:ok, changeset} = Board.build(board, %{})

      put_assoc(changeset, :members, [member])
      |> Repo.update!()
    end)
    |> case do
      {:ok, _} = return ->
        return

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end
end
