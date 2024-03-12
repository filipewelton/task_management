defmodule TaskManagement.Boards.AddMemberTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias Ecto.Changeset
  alias TaskManagement.Boards.AddMember

  setup do
    user = insert(:user_struct)
    member = insert(:member_struct, user_id: user.id)
    board = insert(:board_struct, members: [member])

    %{
      owner: user,
      board_id: board.id
    }
  end

  describe "call/1" do
    test "when the member role is invalid", %{board_id: board_id, owner: owner} do
      user = insert(:user_struct)

      payload = %{
        role: "unknown",
        board_id: board_id,
        user_id: user.id
      }

      response = AddMember.call(payload, owner)

      assert {:error, %Changeset{valid?: false}} = response
    end

    test "when the executor does not have permission for thins resource", %{
      board_id: board_id,
    } do
      owner = insert(:user_struct)
      user = insert(:user_struct)

      payload = %{
        role: "unknown",
        board_id: board_id,
        user_id: user.id
      }

      response = AddMember.call(payload, owner)

      assert {:error, "You do not have permission for this resource!", 403} = response
    end

    test "when the member is already listed", %{board_id: board_id, owner: owner} do
      user = insert(:user_struct)

      payload = %{
        role: "master",
        board_id: board_id,
        user_id: user.id
      }

      {:ok, _response} = AddMember.call(payload, owner)
      response = AddMember.call(payload, owner)

      assert {:error, "This user is already listed!", 409} = response
    end

    test "when the member is added", %{board_id: board_id, owner: owner} do
      user = insert(:user_struct)

      payload = %{
        role: "master",
        board_id: board_id,
        user_id: user.id
      }

      {:ok, response} = AddMember.call(payload, owner)

      assert Map.has_key?(response, :board_id)
      assert Map.has_key?(response, :members)
    end
  end
end
