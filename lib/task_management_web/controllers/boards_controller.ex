defmodule TaskManagementWeb.BoardsController do
  use TaskManagementWeb, :controller

  import TaskManagement

  alias TaskManagement.Repo
  alias TaskManagement.User
  alias TaskManagementWeb.FallbackController

  action_fallback FallbackController

  def create(conn, raw_payload) do
    payload = parse_request_params(raw_payload)

    with {:ok, board} <- create_board(payload) do
      board = Repo.preload(board, [:members, :tasks])

      conn
      |> put_status(201)
      |> render("create.json", board: board)
    end
  end

  def delete(conn, %{"id" => id}) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)

    with :ok <- delete_board(id, executor) do
      conn
      |> put_status(204)
      |> text("")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, board} <- get_board_by_id(id) do
      board = Repo.preload(board, [:members, :tasks])

      conn
      |> put_status(200)
      |> render("show.json", board: board)
    end
  end

  def update(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with %User{} <- executor,
         {:ok, board} <- update_board(payload, executor) do
      board = Repo.preload(board, [:members, :tasks])

      conn
      |> put_status(200)
      |> render("update.json", board: board)
    end
  end

  def add_member(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, response} <- add_member_to_board(payload, executor) do
      conn
      |> put_status(201)
      |> render("add_member.json", response: response)
    end
  end

  def remove_member(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, response} <- remove_member_from_board(payload, executor) do
      conn
      |> put_status(204)
      |> render("remove_member.json", response: response)
    end
  end

  def update_member(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, board_id, member} <- update_member_from_board(payload, executor) do
      conn
      |> put_status(200)
      |> render("update_member.json", board_id: board_id, member: member)
    end
  end
end
