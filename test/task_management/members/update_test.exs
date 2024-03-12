defmodule TaskManagement.Members.UpdateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias Ecto.Changeset
  alias TaskManagement.Member
  alias TaskManagement.Members.Update

  setup do
    user = insert(:user_struct)
    owner_member = insert(:member_struct, user_id: user.id)
    board = insert(:board_struct, members: [owner_member])

    %{
      owner: user,
      board: board
    }
  end

  describe "call/1" do
    test "when the member role is invalid", %{owner: owner, board: board} do
      member = insert(:member_struct, board: board, role: "master")

      args = %{
        member_id: member.id,
        board_id: board.id,
        role: "unknown"
      }

      response = Update.call(args, owner)

      {:error, %Changeset{valid?: false}} = response
    end

    test "when the executing user does not have permission for this resource" do
      owner = insert(:user_struct)
      owner_member = insert(:member_struct, role: "team", user_id: owner.id)
      board = insert(:board_struct, members: [owner_member])
      member = insert(:member_struct, board: board, role: "team")

      args = %{
        board_id: board.id,
        member_id: member.id,
        role: "master"
      }

      response = Update.call(args, owner)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the member role is update", %{owner: owner, board: board} do
      member = insert(:member_struct, board: board, role: "team")

      args = %{
        member_id: member.id,
        board_id: board.id,
        role: "master"
      }

      response = Update.call(args, owner)

      assert {:ok, _board_id, %Member{}} = response
    end
  end
end
