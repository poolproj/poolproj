# lib/pool_proj/query.ex

defmodule PoolProj.Query do
  import Ecto.Query
  alias PoolProj.{Repo, Pool, Measurement, Analysis}

  @doc """

  EXAMPLE USAGE:
  iex> PoolProj.Query.get_pool_ids()

  Copy one of those IDS and pass into these:
  iex> PoolProj.Query.get_analysis_by_pool_id(pool_id)
  iex> PoolProj.Query.get_measurements_by_pool_id(pool_id)
  iex> PoolProj.Query.get_latest_measurement_by_pool_id(pool_id)
  iex> PoolProj.Query.get_analysis_by_measurement_id(pool_id)


  iex> PoolProj.Query.count_pools()
  iex> PoolProj.Query.average_pool_volume()
  """

  # Get all pool IDs
  def get_pool_ids do
    from(p in Pool, select: p.id)
    |> Repo.all()
  end

  # Get analysis by pool_id
  def get_analysis_by_pool_id(pool_id) do
    from(a in Analysis,
      join: m in assoc(a, :measurement),
      join: p in assoc(m, :pool),
      where: p.id == ^pool_id,
      select: a
    )
    |> Repo.all()
  end

  # Get measurements by pool_id
  def get_measurements_by_pool_id(pool_id) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id,
      select: m
    )
    |> Repo.all()
  end

  # Get the latest measurement for a pool
  def get_latest_measurement_by_pool_id(pool_id) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id,
      order_by: [desc: m.date],
      limit: 1,
      select: m
    )
    |> Repo.one()
  end

  # Get analysis for a specific measurement
  def get_analysis_by_measurement_id(measurement_id) do
    from(a in Analysis,
      where: a.measurement_id == ^measurement_id,
      select: a
    )
    |> Repo.one()
  end

  # Get all pools in a specific location
  def get_pools_by_location(location) do
    from(p in Pool,
      where: p.location == ^location,
      select: p
    )
    |> Repo.all()
  end

  # Get measurements within a date range
  def get_measurements_by_pool_id_and_date_range(pool_id, start_date, end_date) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id and m.date >= ^start_date and m.date <= ^end_date,
      select: m
    )
    |> Repo.all()
  end

  # Get all analysis with a specific status
  def get_analysis_by_status(status) do
    from(a in Analysis,
      where: a.status == ^status,
      select: a
    )
    |> Repo.all()
  end

  # Get the total number of pools
  def count_pools do
    from(p in Pool, select: count(p.id))
    |> Repo.one()
  end

  # Get average pool volume
  def average_pool_volume do
    from(p in Pool, select: avg(p.volume))
    |> Repo.one()
  end
end
