defmodule TaskManagement.Tasks.CreateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Task
  alias TaskManagement.Tasks.Create

  describe "call/1" do
    test "when the member does not have permission to create a task" do
      user = insert(:user_struct)
      member = insert(:member_struct, role: "team", user_id: user.id)
      task = build(:task, member_id: member.id)
      response = Create.call(task, user)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the task is created" do
      user = insert(:user_struct)
      member = insert(:member_struct, role: "master", user_id: user.id)
      board = insert(:board_struct, members: [member])
      task = build(:task, board_id: board.id)
      response = Create.call(task, user)

      assert {:ok, %Task{}} = response
    end
  end
end
