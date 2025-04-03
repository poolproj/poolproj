defmodule PoolProj.Repo.Migrations.CreatePoolData do
  use Ecto.Migration

  def change do
    create table(:pool_data) do
      add :free_chlorine, :float
      add :combined_chlorine, :float
      add :pH, :float
      add :total_alkalinity, :integer
      add :calcium_hardness, :integer
      add :pool_volume, :integer
      add :location, :string

      timestamps()
    end
  end
end

