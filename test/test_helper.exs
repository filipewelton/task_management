ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(TaskManagement.Repo, :manual)
Application.ensure_all_started(:ex_machina)
