import Config

config :task_management, TaskManagement.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "task_management_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :task_management, TaskManagementWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nJ8uC+JdkauImwv20XZ2jp3qYs9gwOG5BW9+zq+df8thmaYZMup/6n944OpgCOir",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
