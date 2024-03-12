defmodule TaskManagementWeb.Plugs.Auth.ErrorHandler do
  import Plug.Conn, only: [put_resp_header: 3, resp: 3]

  alias Guardian.Plug.ErrorHandler

  @behaviour ErrorHandler

  @impl true
  def auth_error(conn, {_error, reason}, _opts) do
    body = Jason.encode!(%{message: to_string(reason)})

    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(401, body)
  end
end
