defmodule AwesomeElixir.Category do
  alias AwesomeElixir.Category
  alias AwesomeElixir.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  schema "category" do
    field :name, :string
    field :description, :string
    has_many :repo, Category.Repo

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end

  def categories_and_repos(size) do
    # Filter not existing repos, filter by min_size parameter
    repos_query = from r in Category.Repo,
      order_by: [asc: r.name],
      where: not is_nil(r.name) and r.stars >= ^size,
      select: r

    query = from p in Category,
      order_by: [asc: p.name],
      preload: [repo: ^repos_query],
      select: p

    Repo.all(query)
    |>Enum.filter(fn el -> length(el.repo) > 0 end)
  end

end
