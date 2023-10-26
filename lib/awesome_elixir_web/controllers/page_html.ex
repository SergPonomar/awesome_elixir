defmodule AwesomeElixirWeb.PageHTML do
  use AwesomeElixirWeb, :html
  use Phoenix.Component

  embed_templates "page_html/*"

  attr :name, :string, default: "elixir-combination"
  attr :description, :string, default: "A simple combinatorics library providing combination and permutation."
  attr :stars, :integer, default: 30
  attr :last_commited, :string, default: "2018-02-25"
  attr :path, :string, default: "seantanly/elixir-combination"

  def repo_card(assigns) do
    ~H"""
    <div class="repo-card">
      <div class="repo-card__header">
        <a
          class="repo-card__title"
          href={"https://github.com/" <> @path}
        >
          <h2><%= @name %></h2>
        </a>
        <div class="repo-card__stars">
          <img
            class="repo-card__star"
            src={~p"/images/star.svg"}
            name="star"
          />
          <span><%= @stars %></span>
        </div>
      </div>
      <div class="repo-card__description">
        <%= @description %>
      </div>
      <span class="repo-card__updated">updated: <%= @last_commited %></span>
    </div>
    """
  end
end
