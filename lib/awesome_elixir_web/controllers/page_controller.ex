defmodule AwesomeElixirWeb.PageController do
  alias AwesomeElixir.Category
  use AwesomeElixirWeb, :controller

  def home(conn, params) do
    stars_param = params["min_stars"]

    min_stars = if is_binary(stars_param) do
      case Integer.parse(stars_param) do
        {val, _} when val > 0 -> val
        _ -> 0 
      end
    else
      0
    end

    categories = Category.categories_and_repos(min_stars)
    render(conn, :home, [layout: false, categories: categories])
  end

  def redirect_home(conn, _params) do
    redirect(conn, to: ~p"/")
  end

end