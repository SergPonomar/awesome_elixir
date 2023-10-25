defmodule AwesomeElixir.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:category) do
      add :name, :text, unique: true
      add :description, :string

      timestamps()
    end

    create unique_index(:category, [:name])
  end
end
