defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(
        scheme: :http,
        plug: MyApp.Router,
        options: [port: 8085]
      )
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule MyApp.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  
  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> MyApp.Router.parse("CREATE shopping\r\n")
      {:ok, {:create, "shopping"}}

  """
  def parse(_line) do
    :not_implemented
  end

  get "/health" do
    send_resp(conn, 200, "Ok")
  end

  # Basic example to handle POST requests wiht a JSON body
  post "/post" do
    {:ok, body, conn} = read_body(conn)
    body = Poison.decode!(body)
    IO.inspect(body)
    send_resp(conn, 201, "created: #{get_in(body, ["message"])}\n")
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, "not found")
  end

end
