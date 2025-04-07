defmodule PoolProj.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :pool_id, references(:pools, on_delete: :delete_all)
      add :date, :date

      add :free_chlorine, :float
      add :combined_chlorine, :float
      add :pH, :float
      add :total_alkalinity, :integer
      add :calcium_hardness, :integer

      timestamps()
    end

    create index(:measurements, [:pool_id])
  end
end
