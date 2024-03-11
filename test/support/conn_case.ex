defmodule TaskManagementWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint TaskManagementWeb.Endpoint

      use TaskManagementWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import TaskManagementWeb.ConnCase
    end
  end

  setup tags do
    TaskManagement.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
