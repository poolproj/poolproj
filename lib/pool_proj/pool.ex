defmodule PoolProj.Pool do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pools" do
    field :location, :string
    field :volume, :integer

    has_many :measurements, PoolProj.Measurement

    timestamps()
  end

  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:location, :volume])
    |> validate_required([:location, :volume])
  end
end
