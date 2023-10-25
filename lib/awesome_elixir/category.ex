defmodule AwesomeElixir.Category do
  alias AwesomeElixir.Category.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "category" do
    field :name, :string
    field :description, :string
    has_many :repo, Repo

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
