defmodule TaskManagementWeb.FallbackController do
  use TaskManagementWeb, :controller

  alias Ecto.Changeset
  alias TaskManagementWeb.ErrorJSON

  def call(conn, {:error, reason, status_code}) do
    conn
    |> put_status(status_code)
    |> put_view(ErrorJSON)
    |> render("error.json", reason: reason)
  end

  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(ErrorJSON)
    |> render("error.json", reason: changeset)
  end
end
