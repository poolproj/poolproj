defmodule PoolProj.Analysis do
  use Ecto.Schema
  import Ecto.Changeset

  schema "analysis" do
    field :status, :string
    field :recommendation, :string

    belongs_to :measurement, PoolProj.Measurement

    timestamps()
  end

  def changeset(analysis, attrs) do
    analysis
    |> cast(attrs, [:status, :recommendation, :measurement_id])
    |> validate_required([:status, :recommendation, :measurement_id])
  end
end
