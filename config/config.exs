import Config

config :task_management,
  ecto_repos: [TaskManagement.Repo],
  generators: [timestamp_type: :utc_datetime]

config :task_management, TaskManagementWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: TaskManagementWeb.ErrorHTML, json: TaskManagementWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TaskManagement.PubSub,
  live_view: [signing_salt: "5A8nz+D1"]

config :task_management, amqp_uri: "amqp://rabbitmq:rabbitmq@localhost"

config :task_management, TaskManagementWeb.Plugs.Auth.Guard,
  issuer: "Task Management",
  secret_key: "5mjtFPEkhB/Hlx4D5e2xw4C+mp2G43iRtcg3TpRnMYkD/q33z0webwvzIQeIAzB2"

config :task_management, TaskManagementWeb.Plugs.Auth.UserPipeline,
  module: TaskManagementWeb.Plugs.Auth.Guard,
  error_handler: TaskManagementWeb.Plugs.Auth.ErrorHandler

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
