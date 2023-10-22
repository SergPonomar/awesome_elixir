defmodule AwesomeElixirWeb.Router do
  use AwesomeElixirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AwesomeElixirWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AwesomeElixirWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/*anything", PageController, :redirect_home
  end

  # Other scopes may use custom stacks.
  # scope "/api", AwesomeElixirWeb do
  #   pipe_through :api
  # end
end
