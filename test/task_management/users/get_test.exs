defmodule TaskManagement.Users.GetTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.User
  alias TaskManagement.Users.Get

  describe "by_id/1" do
    test "when id is invalid" do
      response = Get.by_id(Faker.String.base64())
      assert {:error, "User id is invalid!", 400} = response
    end

    test "when the id is not found" do
      response = Get.by_id(Faker.UUID.v4())
      assert {:error, "User not found!", 404} = response
    end

    test "when the id is found" do
      %User{id: id} = insert(:user_struct)
      response = Get.by_id(id)
      assert {:ok, %User{}} = response
    end
  end

  describe "by_email/1" do
    test "when the email is nil" do
      response = Get.by_email(nil)
      assert {:error, "User email is required!", 400} = response
    end

    test "when the email is not a string" do
      response = Get.by_email(true)
      assert {:error, "User email must be of type string!", 400} = response
    end

    test "when the email is not found" do
      response = Get.by_email(Faker.Internet.email())
      assert {:error, "User not found!", 404} = response
    end

    test "when the email is found" do
      email = Faker.Internet.email()

      insert(:user_struct, email: email)

      response = Get.by_email(email)
      assert {:ok, %User{}} = response
    end
  end
end
