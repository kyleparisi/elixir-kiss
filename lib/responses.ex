defmodule Responses do
  import Plug.Conn

  def json_resp(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Poison.encode!(body) <> "\n")
  end
end
