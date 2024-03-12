defmodule TaskManagement.Members.DeleteTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagement.Member
  alias TaskManagement.Members.Delete

  describe "call/1" do
    test "when the member is deleted" do
      %Member{id: id} = insert(:member_struct)
      response = Delete.call(id)

      assert :ok = response
    end
  end
end
