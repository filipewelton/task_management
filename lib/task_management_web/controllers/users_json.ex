defmodule TaskManagementWeb.UsersJSON do
  def render("login.json", payload) do
    Map.take(payload, [:user, :token])
  end

  def render(_template, payload) do
    Map.take(payload, [:user])
  end
end
