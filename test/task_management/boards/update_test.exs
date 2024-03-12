defmodule TaskManagement.Boards.UpdateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Board
  alias TaskManagement.Boards.Update

  describe "call/1" do
    test "when the board is updated" do
      owner = insert(:user_struct)
      member = insert(:member_struct, user_id: owner.id)
      board = insert(:board_struct, members: [member])
      board_name = Faker.Lorem.word()
      board_description = Faker.Lorem.sentence()

      args = %{
        id: board.id,
        name: board_name,
        description: board_description
      }

      response = Update.call(args, owner)

      assert {:ok, %Board{}} = response
    end
  end

  test "when the board is updated" do
    owner = insert(:user_struct)
    member = insert(:member_struct, user_id: owner.id, role: "team")
    board = insert(:board_struct, members: [member])
    board_name = Faker.Lorem.word()
    board_description = Faker.Lorem.sentence()

    args = %{
      id: board.id,
      name: board_name,
      description: board_description
    }

    response = Update.call(args, owner)

    assert {:error, "You do not have permission for this resource!", 403} = response
  end
end
