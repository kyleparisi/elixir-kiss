defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: MyPlug, options: [port: 4001]},
      {MyXQL, username: "application", hostname: "localhost", password: "bleepbloop", database: "myapp", name: :myapp_db}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule DB do

  def paginate(query) do
    query = String.replace(query, ";", "") |> String.trim
    query <> " LIMIT 0,100;"
  end

  def paginate(query, page) do
    query = String.replace(query, ";", "") |> String.trim
    query <> " LIMIT #{page * 100},#{page * 100 + 100};"
  end

  def query(query, repo, params \\ []) do
    MyXQL.query(repo, query, params) |> to_maps
  end

  # Insert
  def to_maps({:ok, %MyXQL.Result{last_insert_id: id, columns: nil, rows: nil}}) when id > 0 do
    %{id: id}
  end

  # Update/Delete
  def to_maps({:ok, %MyXQL.Result{last_insert_id: 0, columns: nil, rows: nil}}) do
    :ok
  end

  # Select
  def to_maps({:ok, %MyXQL.Result{columns: columns, rows: rows}}) do
    Enum.map(rows, fn row ->
      columns
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
  end
end

defmodule Router do
  def match("GET", ["health"], _conn) do
    "Ok"
  end

  def match("GET", ["hello", name], _conn) do
    "Hello #{name}"
  end

  def match("GET", ["hello2", name], _conn) do
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
        send_resp(conn, 200, res <> "\n")
    end
  end
end
