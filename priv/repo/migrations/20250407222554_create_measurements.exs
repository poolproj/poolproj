defmodule PoolProj.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :pool_id, references(:pools, on_delete: :delete_all)
      add :date, :date

      add :free_chlorine, :float
      add :combined_chlorine, :float
      add :pH, :float
      add :total_alkalinity, :float
      add :calcium_hardness, :float

      timestamps()
    end

    create index(:measurements, [:pool_id])
  end
end
