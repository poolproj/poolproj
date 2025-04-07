defmodule PoolProj.Repo.Migrations.CreateAnalysis do
  use Ecto.Migration

  def change do
    create table(:analysis) do
      add :measurement_id, references(:measurements, on_delete: :delete_all)
      add :status, :string
      add :recommendation, :text

      timestamps()
    end

    create index(:analysis, [:measurement_id])
  end
end

