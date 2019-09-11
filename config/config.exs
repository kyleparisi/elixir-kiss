use Mix.Config

config :myapp, Users.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "myapp_repo",
  username: "kyleparisi",
  password: "",
  hostname: "localhost"

config :myapp, ecto_repos: [Users.Repo]
