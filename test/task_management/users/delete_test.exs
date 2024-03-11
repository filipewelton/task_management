defmodule TaskManagement.Users.DeleteTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Users.Delete

  describe "call/1" do
    test "when the user is deleted" do
      user = insert(:user_struct)
      response = Delete.call(user)

      assert :ok = response
    end
  end
end
