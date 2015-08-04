defmodule RefluxEventbrokerReactPhoenixElixir.PageController do
  use RefluxEventbrokerReactPhoenixElixir.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
