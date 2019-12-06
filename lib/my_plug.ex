defmodule MyPlug do
  import Plug.Conn
  import Responses

  def init(opts), do: opts

  def call(conn, _opts) do
    res = Router.match(conn.method, conn.path_info, conn)

    # things like put_session modify the connection, so a mechanism to replace the
    # connection in the plug is needed
    {conn, res} =
      case res do
        {:conn, new_conn, new_res} -> {new_conn, new_res}
        _ -> {conn, res}
      end

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
