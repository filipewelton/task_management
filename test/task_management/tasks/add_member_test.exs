defmodule TaskManagement.Task.AddMemberTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Tasks.AddMember, as: AddMemberToTask

  describe "call/1" do
    test "when the member is not listed no the board" do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id, role: "master")
      board = insert(:board_struct, members: [member])
      task = insert(:task_struct, board: board)
      master_member = insert(:member_struct, role: "master")

      payload = %{
        task_id: task.id,
        member_id: master_member.id
      }

      response = AddMemberToTask.call(payload, user)

      assert {:error, "This member is not listed on the board!", 409} = response
    end

    test "when the member is already listed on the task" do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id, role: "master")
      master_member = insert(:member_struct, role: "master")
      board = insert(:board_struct, members: [member, master_member])
      task = insert(:task_struct, board: board, members: [member, master_member])

      payload = %{
        task_id: task.id,
        member_id: master_member.id
      }

      response = AddMemberToTask.call(payload, user)

      assert {:error, "This member already listed in the task!", 409} = response
    end

    test "when the member is not listed on the board" do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id, role: "master")
      master_member = insert(:member_struct, role: "master")
      board = insert(:board_struct, members: [member])
      task = insert(:task_struct, board: board)

      payload = %{
        task_id: task.id,
        member_id: master_member.id
      }

      response = AddMemberToTask.call(payload, user)

      assert {:error, "This member is not listed on the board!", 409} = response
    end

    test "when the member is added to task" do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id, role: "master")
      master_member = insert(:member_struct, role: "master")
      board = insert(:board_struct, members: [member, master_member])
      task = insert(:task_struct, board: board)

      payload = %{
        task_id: task.id,
        member_id: master_member.id
      }

      {:ok, response} = AddMemberToTask.call(payload, user)

      assert Map.has_key?(response, :task_id)
      assert Map.has_key?(response, :members)
    end
  end
end
