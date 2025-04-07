defmodule PoolProj.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add :location, :string
      add :volume, :integer

      timestamps()
    end
  end
end

