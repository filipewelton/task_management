defmodule TaskManagement.Users.ConnectTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.User
  alias TaskManagement.Users.Connect

  describe "call/1" do
    test "when the password is invalid" do
      email = Faker.Internet.email()

      payload = %{
        email: email,
        password: Faker.String.base64(12)
      }

      insert(:user_struct, email: email)

      response = Connect.call(payload)

      assert {:error, "Invalid password!", 401} = response
    end

    test "when the user is authenticated" do
      email = Faker.Internet.email()
      password = Faker.String.base64(12)
      hash = Bcrypt.hash_pwd_salt(password)

      payload = %{
        email: email,
        password: password
      }

      insert(:user_struct, email: email, password: hash)

      response = Connect.call(payload)

      assert {:ok, %User{}} = response
    end
  end
end
