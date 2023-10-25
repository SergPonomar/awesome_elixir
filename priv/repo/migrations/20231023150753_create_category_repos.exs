defmodule AwesomeElixir.Repo.Migrations.CreateRepo do
  use Ecto.Migration

  def change do
    create table(:repo) do
      add :name, :string
      add :description, :text
      add :stars, :integer
      add :last_commited, :date
      add :path, :string, unique: true
      add :category_id, references(:category)

      timestamps()
    end

    create unique_index(:repo, [:path])
  end
end
