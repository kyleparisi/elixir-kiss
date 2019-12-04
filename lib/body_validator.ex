defmodule BodyValidator do
  import Plug.Conn
  import Responses

  def init(opts), do: opts

  def call(conn, _opts) do
    validations = Router.validate_body(conn.method, conn.path_info, conn)

    errors =
      Enum.reduce(validations, %{}, fn {key, value}, acc ->
        case value do
          {:error, msg} -> Map.put(acc, key, msg)
          _ -> acc
        end
      end)

    if Enum.empty?(errors) do
      conn
    else
      json_resp(conn, 422, errors) |> halt
    end
  end
end
