defmodule TaskManagement.Tasks.UpdateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias Ecto.Changeset
  alias TaskManagement.{ChecklistItem, Task}
  alias TaskManagement.Tasks.Update

  setup do
    user = insert(:user_struct)
    member = insert(:member_struct, user_id: user.id)
    board = insert(:board_struct, members: [member])

    %{user: user, board: board}
  end

  describe "call/1" do
    test "when the labels has invalid values", %{user: user, board: board} do
      task = insert(:task_struct, board: board)

      payload = %{
        id: task.id,
        labels: [Faker.String.base64()]
      }

      response = Update.call(payload, user)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the checklist has invalid values", %{user: user, board: board} do
      task = insert(:task_struct, board: board)

      payload = %{
        id: task.id,
        checklist: [%{}]
      }

      response = Update.call(payload, user)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the checklist has valid values", %{user: user, board: board} do
      task = insert(:task_struct, board: board)

      payload = %{
        id: task.id,
        checklist: [%ChecklistItem{title: Faker.Lorem.sentence(), checked: true}]
      }

      response = Update.call(payload, user)

      assert {:ok, %Task{}} = response
    end

    test "when the status is invalid", %{user: user, board: board} do
      task = insert(:task_struct, board: board)

      payload = %{
        id: task.id,
        status: "unknown"
      }

      response = Update.call(payload, user)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the task is updated", %{user: user, board: board} do
      task = insert(:task_struct, board: board)

      payload = %{
        id: task.id,
        status: "done",
        labels: [Faker.Lorem.word()]
      }

      response = Update.call(payload, user)

      assert {:ok, %Task{}} = response
    end
  end
end
