defmodule Session do
  @behavior Plug.Session.Store

  def init(opts \\ []), do: opts

  def get(_conn, cookie, _opts)
      when cookie == ""
      when cookie == nil do
    {nil, %{}}
  end

  def get(_conn, sid, opts) do
    sessions = "SELECT * FROM session WHERE sid = '?' LIMIT 1;" |> DB.query(:db, [sid])
    if Enum.empty?(sessions) do
      {nil, %{}}
    else
      {sid, hd(sessions)}
    end
  end

  def put(conn, nil, data, init_options) do
    put(conn, generate_random_key(), data, init_options)
  end

  def put(conn, sid, data, opts) do
    now = DateTime.utc_now()
    datetime = DateTime.to_string(%{now | microsecond: {0, 0}}) |> String.replace("Z", "")
    timestamp = DateTime.to_unix(now)
    "INSERT INTO session SET sid = ?, expire = ?, date_time = ?" |> DB.query(:db, [sid, timestamp, datetime])
    sid
  end

  def delete(conn, sid, opts) do
  end

  defp generate_random_key do
    :crypto.strong_rand_bytes(96) |> Base.encode64()
  end
end
