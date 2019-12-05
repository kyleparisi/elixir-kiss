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
       username: "application",
       hostname: "localhost",
       password: "bleepbloop",
       database: "myapp",
       name: :db}
    ]

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

defmodule Pinger.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end
end

defmodule Router do
  import Validations

  def validate_body("POST", ["login"], conn),
    do: [
      validate_not_empty("email", conn.body_params["email"]),
      validate_not_empty("password", conn.body_params["email"])
    ]

  def validate_body(_, _, _), do: []

  def validate_path("GET", ["user", id], _conn), do: [validate_integer("id", id)]
  def validate_path(_, _, _), do: []

  def match("GET", ["health"], _conn) do
    "Ok"
  end

  def match("GET", ["hello", name], _conn) do
    "Hello #{name}"
  end

  def match("GET", ["hello2", name], _conn) do
    {:render, "views/hello.html.eex", %{name: name}}
  end

  def match("GET", ["user", _id], conn) do
    "SELECT * FROM user where id = ?" |> DB.query(:db, [conn.path_params["id"]]) |> hd
  end

  def match("POST", ["echo"], conn) do
    IO.inspect(conn.body_params)
    conn.body_params
  end

  def match(_, _, _) do
    {:not_found, "Not Found"}
  end
end

defmodule MyPlug do
  import Plug.Conn
  import Responses

  def init(opts), do: opts

  def call(conn, _opts) do
    res = Router.match(conn.method, conn.path_info, conn)

    case get_req_header(conn, "accept") do
      # Handle explicit json requests
      ["application/json"] ->
        case res do
          {:render, _template_path, data} ->
            IO.inspect(data)
            json_resp(conn, 200, data)

          _ ->
            json_resp(conn, 200, res)
        end

      # Otherwise, handle the standard signatures
      _ ->
        case res do
          json when is_map(json) ->
            json_resp(conn, 200, json)

          {:render, template_path, data} ->
            body = EEx.eval_file(template_path, Map.to_list(data))
            send_resp(conn, 200, "#{body}")

          {http_code, body} ->
            send_resp(conn, http_code, "#{body}\n")

          _ ->
            send_resp(conn, 200, "#{res}\n")
        end
    end
  end
end
