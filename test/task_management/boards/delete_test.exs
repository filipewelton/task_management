defmodule TaskManagement.Boards.DeleteTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Boards.Delete

  describe "call/1" do
    test "when the user does not have permission for this resource" do
      user = insert(:user_struct)
      owner_member = insert(:member_struct)
      member = insert(:member_struct, role: "master", user_id: user.id)
      board = insert(:board_struct, members: [owner_member, member])
      response = Delete.call(board.id,  user)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the board is deleted" do
      user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: user.id, role: "owner")
      board = insert(:board_struct, members: [owner_member])
      response = Delete.call(board.id, user)

      assert :ok = response
    end
  end
end
