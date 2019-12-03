defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: MyPlug, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Router do
  def match("GET", ["health"]) do
    "Ok"
  end

  def match("GET", ["hello", name]) do
    "Hello #{name}"
  end

  def match("GET", ["hello2", name]) do
    EEx.eval_file("templates/hello.html.eex", name: name)
  end

  def match("POST", ["echo"], conn) do
    IO.inspect conn.body_params
    conn.body_params
  end

  def match(_, _, _) do
    {:not_found, "Not Found"}
  end
end

defmodule MyPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    parsers = Plug.Parsers.init(parsers: [:json, :urlencoded], json_decoder: Poison)
    conn = Plug.Parsers.call(conn, parsers)
    res = Router.match(conn.method, conn.path_info, conn)

    case res do
      json when is_map(json) ->
        {:ok, res} = Poison.encode(json)
        send_resp(conn, 200, res <> "\n")

      {http_code, body} ->
        send_resp(conn, http_code, body <> "\n")

      _ ->
        send_resp(conn, 200, res)
    end
  end
end
