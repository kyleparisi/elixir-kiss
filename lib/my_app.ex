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

  def handle_login({:error, :invalid, 0}) do
    Logger.info("/login: No body provided.")
    {:error, %{errors: %{email: "Please provide an email.", password: "Please provide a password."}}}
  end

  def handle_login({:ok, %{"email" => "", "password" => ""}}) do
    Logger.info("/login: No values provided.")
    {:error, %{errors: %{email: "Please provide an email.", password: "Please provide a password."}}}
  end

  def handle_login({:ok, %{"email" => email, "password" => password}}) do
    Logger.info("/login")
    {:ok, ""}
  end

  def handle_login({:ok, %{"email" => email}}) do
    Logger.info("/login: No password provided.")
    {:error, %{errors: %{password: "Please provide a password."}, email: email}}
  end

  def handle_login({:ok, %{"password" => _}}) do
    Logger.info("/login: No email provided.")
    {:error, %{errors: %{password: "Please provide an email."}}}
  end


  post "/login" do
    {:ok, body, conn} = read_body(conn)
    body = Poison.decode(body)
    case handle_login(body) do
      {:ok, message} ->
        send_resp(conn, 200, Poison.encode!(message))
      {:error, message} ->
        send_resp(conn, 400, Poison.encode!(message))
    end
  end

  # "Default" route that will get called when no other route is matched
  match _ do
    send_resp(conn, 404, "not found")
  end

end
