defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: nil,
       options: [
         dispatch: dispatch(),
         port: 4001
       ]},
      {MyXQL,
       username: System.get_env("DB_USERNAME"),
       hostname: System.get_env("DB_HOST"),
       password: System.get_env("DB_PASSWORD"),
       database: System.get_env("DB_DATABASE"),
       name: :db}
    ]

    Application.put_env(:myxql, :json_library, Poison, [])

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws", WebSocket, %{}},
         {:_, Plug.Cowboy.Handler, {Pipeline, []}}
       ]}
    ]
  end
end
