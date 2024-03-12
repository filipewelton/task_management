defmodule TaskManagement.Boards.GetTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Board
  alias TaskManagement.Boards.Get

  describe "by_id/1" do
    test "when id is nil" do
      response = Get.by_id(nil)
      assert {:error, "Board id is required!", 400} = response
    end

    test "when id is not a string" do
      response = Get.by_id(true)
      assert {:error, "Board id should be a string!", 400} = response
    end

    test "when the board is not found" do
      id = Faker.UUID.v4()
      response = Get.by_id(id)
      assert {:error, "Board not found!", 404} = response
    end

    test "when the board is found" do
      %Board{id: id} = insert(:board_struct)
      response = Get.by_id(id)
      assert {:ok, %Board{}} = response
    end
  end
end
