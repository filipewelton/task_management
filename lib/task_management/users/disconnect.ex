defmodule TaskManagement.Users.Disconnect do
  alias TaskManagementWeb.Plugs.Auth.Guard

  @spec call(String.t()) :: :ok | tuple()
  def call(token) do
    Guard.revoke(token)
    :ok
  end
end
