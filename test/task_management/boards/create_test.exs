defmodule TaskManagement.Boards.CreateTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias Ecto.Changeset
  alias TaskManagement.Board
  alias TaskManagement.Boards.Create

  setup do
    user = insert(:user_struct)
    %{user_id: user.id}
  end

  describe "call/1" do
    test "when the owner id is not found" do
      payload = %{
        user_id: Faker.UUID.v4(),
        description: Faker.Lorem.sentence(),
        name: Faker.Lorem.word()
      }

      response = Create.call(payload)

      assert {:error, "User not found!", 404} = response
    end

    test "when the board name is invalid", %{user_id: user_id} do
      payload = %{
        user_id: user_id,
        description: Faker.Lorem.sentence(),
        name: Faker.String.base64(31)
      }

      response = Create.call(payload)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the description is invalid", %{user_id: user_id} do
      payload = %{
        user_id: user_id,
        name: Faker.String.base64(),
        description: Faker.String.base64(151)
      }

      response = Create.call(payload)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the board is created", %{user_id: user_id} do
      payload = %{
        user_id: user_id,
        description: Faker.Lorem.sentence(),
        name: Faker.String.base64()
      }

      response = Create.call(payload)

      assert {:ok, %Board{}} = response
    end
  end
end
