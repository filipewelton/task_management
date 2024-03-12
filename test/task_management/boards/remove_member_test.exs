defmodule TaskManagement.Boards.RemoveMemberTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Boards.RemoveMember

  setup do
    executor = insert(:user_struct)
    owner_member = insert(:member_struct, user_id: executor.id)
    master_member = insert(:member_struct)
    board = insert(:board_struct, members: [owner_member, master_member])

    %{
      executor: executor,
      board: board,
      member: master_member
    }
  end

  describe "call/1" do
    test "when the member is not listed", %{executor: executor, board: board} do
      member = insert(:member_struct)

      payload = %{
        board_id: board.id,
        member_id: member.id
      }

      response = RemoveMember.call(payload, executor)

      assert {:error, "This member is not listed!", 409} = response
    end

    test "when the executor does not have permission for this resource", %{
      board: board
    } do
      executor = insert(:user_struct)
      member = insert(:member_struct)

      payload = %{
        board_id: board.id,
        member_id: member.id
      }

      response = RemoveMember.call(payload, executor)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the member is removed from the board", %{
      board: board,
      member: member,
      executor: executor
    } do
      payload = %{
        board_id: board.id,
        member_id: member.id
      }

      {:ok, response} = RemoveMember.call(payload, executor)

      assert Map.has_key?(response, :board_id)
      assert Map.has_key?(response, :members)
    end
  end
end
