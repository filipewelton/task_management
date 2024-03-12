defmodule TaskManagement.Members.Create do
  require Logger

  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.{Member, Repo}
  alias TaskManagement.Users.Get, as: GetUser

  import Ecto.Changeset, only: [change: 2]

  @type args :: %{
          role: String.t(),
          board_id: String.t(),
          user_id: String.t()
        }
  @spec call(args :: args()) :: {:ok, Member} | {:error, any(), integer()}
  def call(args) do
    board_id = Map.get(args, :board_id)
    user_id = Map.get(args, :user_id)

    with {:ok, board} <- GetBoard.by_id(board_id),
         {:ok, user} <- GetUser.by_id(user_id),
         {:ok, changeset} <- Member.build(args),
         changeset <- change(changeset, %{board: board}),
         changeset <- change(changeset, %{user: user}) do
      create_member(changeset)
    end
  end

  defp create_member(member) do
    case Repo.insert(member) do
      {:ok, _} = response ->
        response

      # coveralls-ignore-start
      {:error, reason} ->
        Logger.error(reason)
        {:error, "Unknown error.", 500}
        # coveralls-ignore-stop
    end
  end
end
