defmodule TaskManagement.Tasks.GetTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Task
  alias TaskManagement.Tasks.Get

  describe "by_board_id/1" do
    test "when the board id is invalid format" do
      id = Faker.String.base64()
      response = Get.by_board_id(id)

      assert {:error, "Board id should be valid UUID!", 400} = response
    end

    test "when the task is found" do
      %Task{board_id: board_id} = insert(:task_struct)
      response = Get.by_board_id(board_id)

      assert {:ok, [%Task{}]} = response
    end
  end

  describe "by_id/1" do
    setup do
      user = insert(:user_struct)
      member = insert(:member_struct, user_id: user.id)
      board = insert(:board_struct, members: [member])
      task = insert(:task_struct, board: board)

      %{user: user, task_id: task.id}
    end

    test "when the executor does not have permission for this resource" do
      user = insert(:user_struct)
      task = insert(:task_struct)
      response = Get.by_id(task.id, user)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the task id is invalid format", %{user: user} do
      id = Faker.String.base64()
      response = Get.by_id(id, user)

      assert {:error, "Invalid task id format!", 400} = response
    end

    test "when the task was not found", %{user: user} do
      id = Faker.UUID.v4()
      response = Get.by_id(id, user)

      assert {:error, "Task not found!", 404} = response
    end

    test "when the executor is null", %{task_id: task_id} do
      response = Get.by_id(task_id, nil)

      assert {:ok, %Task{}} = response
    end

    test "when the executor is owner or master", %{user: user, task_id: task_id} do
      response = Get.by_id(task_id, user)

      assert {:ok, %Task{}} = response
    end
  end
end
