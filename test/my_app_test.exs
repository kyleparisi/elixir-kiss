defmodule MyAppTest do
  use ExUnit.Case
  use Plug.Test

  require Poison

  alias MyApp.Router

  @opts Router.init([])

  Logger.configure(level: :info)

  test "/health returns ok" do
    conn =
      :get
      |> conn("/health", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Ok"
  end

  test "/login with no email or password" do
    conn =
      :post
      |> conn("/login", "")
      |> Router.call(@opts)

    body = Poison.decode(conn.resp_body)
    assert conn.status == 400
  end

  test "/login with no password" do
    conn =
      :post
      |> conn("/login", Poison.encode!(%{email: "abc"}))
      |> Router.call(@opts)

    body = Poison.decode(conn.resp_body)
    assert conn.status == 400
  end

  test "/login with no email" do
    conn =
      :post
      |> conn("/login", Poison.encode!(%{password: "abc"}))
      |> Router.call(@opts)

    body = Poison.decode(conn.resp_body)
    assert conn.status == 400
  end

  test "/login" do
    conn =
      :post
      |> conn("/login", Poison.encode!(%{email: "abc", password: "abc"}))
      |> Router.call(@opts)

    body = Poison.decode(conn.resp_body)
    assert conn.status == 200
  end
end
