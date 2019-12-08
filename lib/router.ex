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

  def match("GET", ["session"], conn) do
    str = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    conn = Plug.Conn.put_session(conn, :test, str)
    {:conn, conn, Plug.Conn.get_session(conn)}
  end

  def match(_, _, _) do
    {:not_found, "Not Found"}
  end
end
