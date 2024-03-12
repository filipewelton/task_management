defmodule TaskManagementWeb.TasksController do
  use TaskManagementWeb, :controller

  import TaskManagement

  alias TaskManagementWeb.FallbackController

  action_fallback FallbackController

  def create(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, task} <- create_task(payload, executor) do
      conn
      |> put_status(201)
      |> render("tasks.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)

    with :ok <- delete_task(id, executor) do
      conn
      |> put_status(204)
      |> text("")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, task} <- get_task_by_id(id) do
      conn
      |> put_status(200)
      |> render("tasks.json", task: task)
    end
  end

  def update(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, task} <- update_task(payload, executor) do
      conn
      |> put_status(200)
      |> render("tasks.json", task: task)
    end
  end

  def add_member(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, task} <- add_member_to_task(payload, executor) do
      conn
      |> put_status(200)
      |> render("tasks.json", task: task)
    end
  end

  def remove_member(conn, raw_payload) do
    executor = Map.get(conn, :private) |> Map.get(:guardian_default_resource)
    payload = parse_request_params(raw_payload)

    with {:ok, task} <- remove_member_from_task(payload, executor) do
      conn
      |> put_status(200)
      |> render("tasks.json", task: task)
    end
  end
end
