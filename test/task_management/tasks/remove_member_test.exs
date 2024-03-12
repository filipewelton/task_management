defmodule TaskManagement.Task.RemoveMemberTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Tasks.RemoveMember

  setup do
    user = insert(:user_struct)
    member = insert(:member_struct, user_id: user.id)
    board = insert(:board_struct, members: [member])

    %{board: board, user: user}
  end

  describe "call/1" do
    test "when the member is not listed", %{user: user, board: board} do
      member = insert(:member_struct, board: board, role: "team")
      task = insert(:task_struct, board: board)

      payload = %{
        task_id: task.id,
        member_id: member.id
      }

      response = RemoveMember.call(payload, user)

      assert {:error, "This member is not listed in the task!", 409} = response
    end

    test "when the member is removed from task!", %{board: board, user: user} do
      member = insert(:member_struct, board: board, role: "team")
      task = insert(:task_struct, board: board, members: [member])

      payload = %{
        task_id: task.id,
        member_id: member.id
      }

      {:ok, response} = RemoveMember.call(payload, user)

      assert Map.has_key?(response, :task_id)
      assert Map.has_key?(response, :members)
    end
  end
end
