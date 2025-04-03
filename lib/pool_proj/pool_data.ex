defmodule PoolProj.PoolData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pool_data" do
    field :free_chlorine, :float
    field :combined_chlorine, :float
    field :pH, :float
    field :total_alkalinity, :integer
    field :calcium_hardness, :integer
    field :pool_volume, :integer
    field :location, :string

    timestamps()
  end

  def changeset(pool_data, attrs) do
    pool_data
    |> cast(attrs, [
      :free_chlorine,
      :combined_chlorine,
      :pH,
      :total_alkalinity,
      :calcium_hardness,
      :pool_volume,
      :location
    ])
    |> validate_required([
      :free_chlorine,
      :combined_chlorine,
      :pH,
      :total_alkalinity,
      :calcium_hardness,
      :pool_volume,
      :location
    ])
  end
end
