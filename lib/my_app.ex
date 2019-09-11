defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      Users.Repo
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end
