defmodule TaskManagement.Users.UpdateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.User
  alias TaskManagement.Users.Update

  describe "call/1" do
    test "when the name is updated" do
      user = insert(:user_struct)

      response =
        Update.call(user, %{
          name: "Jane Doe"
        })

      assert {:ok, %User{}} = response
    end

    test "when the password is updated" do
      user = insert(:user_struct)

      response =
        Update.call(user, %{
          password: Faker.String.base64(12)
        })

      assert {:ok, %User{}} = response
    end
  end
end
