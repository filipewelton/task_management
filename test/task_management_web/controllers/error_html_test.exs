defmodule TaskManagementWeb.ErrorHTMLTest do
  use TaskManagementWeb.ConnCase

  test "when the route is not found", %{conn: conn} do
    conn
    |> get("/api/dashboard")
    |> response(404)
  end
end
