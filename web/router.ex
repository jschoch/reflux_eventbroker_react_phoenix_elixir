defmodule RefluxEventbrokerReactPhoenixElixir.Router do
  use RefluxEventbrokerReactPhoenixElixir.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RefluxEventbrokerReactPhoenixElixir do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RefluxEventbrokerReactPhoenixElixir do
  #   pipe_through :api
  # end
end
