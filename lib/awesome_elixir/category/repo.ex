defmodule AwesomeElixir.Category.Repo do
  alias AwesomeElixir.Category
  use Ecto.Schema
  import Ecto.Changeset

  schema "repo" do
    field :name, :string
    field :description, :string
    field :stars, :integer
    field :last_commited, :date
    field :path, :string
    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(repo, attrs) do
    repo
    |> cast(attrs, [:name, :description, :stars, :last_commited, :path])
    |> validate_required([:path])
    |> unique_constraint(:path)
  end
end
