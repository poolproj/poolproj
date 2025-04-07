defmodule PoolProj.Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "measurements" do
    field :date, :date
    field :free_chlorine, :float
    field :combined_chlorine, :float
    field :pH, :float
    field :total_alkalinity, :integer
    field :calcium_hardness, :integer

    belongs_to :pool, PoolProj.Pool

    timestamps()
  end

  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [
      :date,
      :free_chlorine,
      :combined_chlorine,
      :pH,
      :total_alkalinity,
      :calcium_hardness,
      :pool_id
    ])
    |> validate_required([
      :date,
      :free_chlorine,
      :combined_chlorine,
      :pH,
      :total_alkalinity,
      :calcium_hardness,
      :pool_id
    ])
  end
end
