defmodule TaskManagement.Users.CreateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias Ecto.Changeset
  alias TaskManagement.User
  alias TaskManagement.Users.Create

  describe "call/1" do
    test "when the name field is invalid" do
      response = Create.call(build(:user, name: "John"))
      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the email is invalid" do
      response = Create.call(build(:user, email: Faker.String.base64()))
      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the password is short" do
      response = Create.call(build(:user, password: Faker.String.base64()))
      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the user is already registered" do
      email = Faker.Internet.email()

      insert(:user_struct, email: email)

      response = Create.call(build(:user, email: email))
      assert {:error, "This user already registered!", 409} = response
    end

    test "when the user is created" do
      response = Create.call(build(:user))
      assert {:ok, %User{}} = response
    end
  end
end
