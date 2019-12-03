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
  def match("GET", ["health"], _conn) do
    "Ok\n"
  end

  def match("GET", ["hello", name], _conn) do
    "Hello #{name}\n"
  end

  def match("GET", ["hello2", name], _conn) do
    EEx.eval_file("templates/hello.html.eex", [name: name])
  end

  def match(_, _, _) do
    {404, "Not Found"}
  end
end


defmodule MyPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    res = Router.match(conn.method, conn.path_info, conn)
    case res do
     {http_code, body} -> send_resp(conn, http_code, body)
      _ -> send_resp(conn, 200, res)
    end
  end
end
