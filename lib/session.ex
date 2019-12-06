defmodule MySession do
  @behaviour Plug.Session.Store

  def init(opts \\ []), do: opts

  def get(_conn, cookie, _opts)
      when cookie == ""
      when cookie == nil do
    {nil, %{}}
  end

  def get(_conn, sid, _opts) do
    IO.puts("get session")
    session = "SELECT data FROM session WHERE sid = ? LIMIT 1;" |> DB.query(:db, [sid]) |> hd
    {:ok, data} = Poison.decode(session["data"])

    if Enum.empty?(session) do
      {nil, %{}}
    else
      {sid, data}
    end
  end

  def put(_conn, nil, data, _opts) do
    IO.puts("new session")
    sid = generate_random_key()
    now = DateTime.utc_now()
    datetime = DateTime.to_string(%{now | microsecond: {0, 0}}) |> String.replace("Z", "")
    timestamp = DateTime.to_unix(now)

    "INSERT INTO session SET sid = ?, expire = ?, date_time = ?, data = ?;"
    |> DB.query(:db, [sid, timestamp, datetime, data])

    sid
  end

  def put(_conn, sid, data, _opts) do
    IO.puts("put session")
    "UPDATE session SET data = ? WHERE sid = ? LIMIT 1;" |> DB.query(:db, [data, sid])
    sid
  end

  def delete(_conn, sid, _opts) do
    "DELETE FROM session where sid = ? LIMIT 1;" |> DB.query(:db[sid])
  end

  defp generate_random_key do
    :crypto.strong_rand_bytes(96) |> Base.encode64()
  end
end
