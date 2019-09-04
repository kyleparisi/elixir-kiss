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

  defmodule User do
    defstruct email: nil, password: nil
  end

  get "/health" do
    send_resp(conn, 200, "Ok")
  end

  post "/login" do
    {:ok, body, conn} = read_body(conn)
    case Poison.decode(body) do
      {:ok, %{"email" => email, "password" => password}} ->
        send_resp(conn, 200, "")
      {:error, :invalid, 0} ->
        Logger.info("No body provided for /login")
        send_resp(conn, 400, Poison.encode!(%{errors: %{email: "Please provide an email.", password: "Please provide a password"}}))
      {:ok, %{"email" => _}} ->
        Logger.info("No password provided for /login")
        send_resp(conn, 400, Poison.encode!(%{errors: %{password: "Please provide a password"}}))
      {:ok, %{"password" => _}} ->
        Logger.info("No email provided for /login")
        send_resp(conn, 400, Poison.encode!(%{errors: %{email: "Please provide an email."}}))
    end
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, "not found")
  end

end
