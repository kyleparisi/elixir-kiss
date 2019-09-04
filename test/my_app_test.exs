defmodule MyAppTest do
  use ExUnit.Case
  use Plug.Test
  doctest MyApp.Router

  alias MyApp.Router

  @opts Router.init([])

  test "returns ok" do
    conn =
      :get
      |> conn("/health", "")
      |> Router.call(@opts)

    IO.inspect conn
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Ok"
  end
end
