defmodule TaskManagement.Members.CreateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Member
  alias TaskManagement.Members.Create

  describe "call/1" do
    test "when the member is created" do
      board = insert(:board_struct)
      user = insert(:user_struct)

      response =
        Create.call(%{
          role: "master",
          board_id: board.id,
          user_id: user.id
        })

      assert {:ok, %Member{}} = response
    end
  end
end
