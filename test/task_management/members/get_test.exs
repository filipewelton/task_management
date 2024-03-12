defmodule TaskManagement.Members.GetTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Member
  alias TaskManagement.Members.Get

  describe "by_id/1" do
    test "when id is invalid" do
      response = Get.by_id(nil)
      assert {:error, "Member id should be a UUID!", 400} = response
    end

    test "when id is not found" do
      response = Get.by_id(Faker.UUID.v4())
      assert {:error, "Member not found!", 404} = response
    end

    test "when id is found" do
      %Member{id: id} = insert(:member_struct)

      response = Get.by_id(id)
      assert {:ok, %Member{}} = response
    end
  end

  describe "by_user_id/1" do
    test "when id is not found" do
      response = Get.by_user_id(Faker.UUID.v4())
      assert {:error, "Member not found!", 404} = response
    end

    test "when id is nil" do
      response = Get.by_user_id(nil)
      assert {:error, "User id should be a UUID!", 400} = response
    end

    test "when id is found" do
      %Member{user_id: id} = insert(:member_struct)

      response = Get.by_user_id(id)
      assert {:ok, %Member{}} = response
    end
  end
end
