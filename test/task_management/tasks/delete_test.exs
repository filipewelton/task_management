defmodule TaskManagement.Tasks.DeleteTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Tasks.Delete

  describe "call/1" do
    test "when the task is deleted" do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id)
      board = insert(:board_struct, members: [member])
      task = insert(:task_struct, members: [member], board: board)
      response = Delete.call(task.id, user)

      assert :ok = response
    end
  end
end
