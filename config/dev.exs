import Config

config :task_management, TaskManagement.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "task_management_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :task_management, TaskManagementWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "LuaGQ3aRubAVUHFrrpkZcPdG9f/UFFszVsIw9VT4Kqh+rnVvw+c1VoXbNi5DCxfU",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :task_management, TaskManagementWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/task_management_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :task_management, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, :debug_heex_annotations, true
