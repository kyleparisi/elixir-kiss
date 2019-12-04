defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: MyPlug, options: [port: 4001]},
      {MyXQL, username: "application", hostname: "localhost", password: "bleepbloop", database: "myapp", name: :db}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Router do
  import Validations

  def validate("GET", ["user", id], _conn), do: [validate_integer("id", id)]
  def validate(_, _, _), do: []

  def match("GET", ["health"], _conn) do
    "Ok"
  end

  def match("GET", ["hello", name], _conn) do
    "Hello #{name}"
  end

  def match("GET", ["hello2", name], _conn) do
    EEx.eval_file("templates/hello.html.eex", name: name)
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

defmodule PathValidator do
  import Plug.Conn
  import Responses

  def init(opts), do: opts

  def call(conn, _opts) do
    validations = Router.validate(conn.method, conn.path_info, conn)

    errors =
      Enum.reduce(validations, %{}, fn {key, value}, acc ->
        case value do
          {:error, msg} -> Map.put(acc, key, msg)
          _ -> acc
        end
      end)

    if Enum.empty?(errors) do
      params = Enum.into(validations, %{})
      put_in(conn.path_params, params)
    else
      json_resp(conn, 422, errors) |> halt
    end
  end
end

defmodule MyPlug do
  import Plug.Conn
  import Responses

  def init(opts), do: opts

  def call(conn, _opts) do
    res = Router.match(conn.method, conn.path_info, conn)

    case res do
      json when is_map(json) ->
        json_resp(conn, 200, json)

      {http_code, body} ->
        send_resp(conn, http_code, body <> "\n")

      _ ->
        send_resp(conn, 200, res <> "\n")
    end
  end
end

defmodule MyPipeline do
  # We use Plug.Builder to have access to the plug/2 macro.
  # This macro can receive a function or a module plug and an
  # optional parameter that will be passed unchanged to the
  # given plug.
  use Plug.Builder

  plug(Plug.Logger)
  plug(PathValidator)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Poison)
  plug(MyPlug)
end
