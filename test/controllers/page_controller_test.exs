defmodule RefluxEventbrokerReactPhoenixElixir.PageControllerTest do
  use RefluxEventbrokerReactPhoenixElixir.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    #assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    assert conn.status == 200
  end
end
