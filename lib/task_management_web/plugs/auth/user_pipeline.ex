defmodule TaskManagementWeb.Plugs.Auth.UserPipeline do
  use Guardian.Plug.Pipeline, otp_app: :task_management

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
