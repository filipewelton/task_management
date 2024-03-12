defmodule TaskManagementWeb.UsersController do
  use TaskManagementWeb, :controller

  import TaskManagement

  alias TaskManagement.User
  alias TaskManagementWeb.FallbackController
  alias TaskManagementWeb.Plugs.Auth.Guard

  action_fallback FallbackController

  def show(conn, _params) do
    user = Map.get(conn, :private) |> Map.get(:guardian_default_resource)

    with %User{} <- user do
      conn
      |> put_status(200)
      |> render("show.json", user: user)
    end
  end

  def login(conn, raw_payload) do
    payload = parse_request_params(raw_payload)

    with {:ok, user} <- connect(payload),
         {:ok, token, _claims} <- Guard.encode_and_sign(user) do
      conn
      |> put_status(200)
      |> render("login.json", user: user, token: token)
    end
  end

  def logout(conn, _params) do
    token =
      Map.get(conn, :private)
      |> Map.get(:guardian_default_token)

    with :ok <- disconnect(token) do
      conn
      |> put_status(204)
      |> text("")
    end
  end

  def create(conn, raw_payload) do
    payload = parse_request_params(raw_payload)

    with {:ok, user} <- create_user(payload) do
      conn
      |> put_status(201)
      |> render("create.json", user: user)
    end
  end

  def delete(conn, _params) do
    user = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    token = Map.get(conn, :private) |> Map.get(:guardian_default_token)

    with %User{} <- user,
         :ok <- delete_user(user),
         {:ok, _claims} <- Guard.revoke(token) do
      conn
      |> put_status(204)
      |> text("")
    end
  end

  def update(conn, raw_payload) do
    user = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with %User{} <- user,
         {:ok, user} <- update_user(user, payload) do
      conn
      |> put_status(200)
      |> render("update.json", user: user)
    end
  end
end
