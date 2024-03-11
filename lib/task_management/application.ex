defmodule TaskManagement.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TaskManagementWeb.Telemetry,
      TaskManagement.Repo,
      {DNSCluster, query: Application.get_env(:task_management, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TaskManagement.PubSub},
      TaskManagementWeb.Endpoint,
      Supervisor.child_spec({Cachex, name: :guardian_tokens}, id: :guardian_tokens),
      Supervisor.child_spec({Cachex, name: :notifications}, id: :notifications),
      Supervisor.child_spec({Cachex, name: :user_sessions}, id: :user_sessions),
    ]

    opts = [strategy: :one_for_one, name: TaskManagement.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TaskManagementWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
