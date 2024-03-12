defmodule TaskManagementWeb.Plugs.Auth.GuardTest do
  use TaskManagement.DataCase

  import TaskManagement.Factory

  alias TaskManagementWeb.Plugs.Auth.Guard

  setup do
    user = insert(:user_struct)
    %{user: user}
  end

  describe "encode_and_sign/1" do
    test "when the token is generated", %{user: user} do
      return = Guard.encode_and_sign(user)
      assert {:ok, _token, _claims} = return
    end

    test "when the subject is invalid" do
      user = %{}
      return = Guard.encode_and_sign(user)
      assert {:error, "Invalid resource."} = return
    end
  end

  describe "revoke" do
    test "when the token is revoked", %{user: user} do
      {:ok, token, _claims} = Guard.encode_and_sign(user)
      {:ok, _claims} = Guard.revoke(token)
      response = Guard.decode_and_verify(token)

      assert {:error, "Unauthenticated."} = response
    end
  end
end
