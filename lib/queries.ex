# lib/pool_proj/query.ex

defmodule PoolProj.Query do
  import Ecto.Query
  alias PoolProj.{Repo, Pool, Measurement, Analysis}

  @moduledoc """
  Provides reusable query functions for accessing pool, measurement, and analysis data
  from the database using Ecto.

  This module simplifies retrieving related data for pools, including historical measurements,
  analyses, and metadata statistics.

  ## Example Usage

  Fetch all pool IDs:

      iex> PoolProj.Query.get_pool_ids()

  Use a pool ID to get related records:

      iex> PoolProj.Query.get_analysis_by_pool_id(pool_id)
      iex> PoolProj.Query.get_measurements_by_pool_id(pool_id)
      iex> PoolProj.Query.get_latest_measurement_by_pool_id(pool_id)
      iex> PoolProj.Query.get_analysis_by_measurement_id(measurement_id)

  Get stats and metrics:

      iex> PoolProj.Query.count_pools()
      iex> PoolProj.Query.average_pool_volume()

  Filter pools or measurements:

      iex> PoolProj.Query.get_pools_by_location("Miami")
      iex> PoolProj.Query.get_measurements_by_pool_id_and_date_range(pool_id, ~D[2024-01-01], ~D[2024-02-01])

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low to Medium
  @since 2025-04-07
  """

  @doc """
  Returns a list of all pool IDs from the database.

  ## Example

      iex> PoolProj.Query.get_pool_ids()
      [1, 2, 3]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Executes a basic select query.
  @since 2025-04-07
  """
  def get_pool_ids do
    from(p in Pool, select: p.id)
    |> Repo.all()
  end

  @doc """
  Returns all analysis records associated with a specific pool ID.

  ## Parameters

    * `pool_id` - The ID of the pool

  ## Example

      iex> PoolProj.Query.get_analysis_by_pool_id(1)
      [%Analysis{}, ...]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium - Requires joins between analysis, measurement, and pool tables.
  @since 2025-04-07
  """
  def get_analysis_by_pool_id(pool_id) do
    from(a in Analysis,
      join: m in assoc(a, :measurement),
      join: p in assoc(m, :pool),
      where: p.id == ^pool_id,
      select: a
    )
    |> Repo.all()
  end

  @doc """
  Returns all measurements for a given pool.

  ## Parameters

    * `pool_id` - The ID of the pool

  ## Example

      iex> PoolProj.Query.get_measurements_by_pool_id(2)
      [%Measurement{}, ...]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Filters measurements by pool ID.
  @since 2025-04-07
  """
  def get_measurements_by_pool_id(pool_id) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id,
      select: m
    )
    |> Repo.all()
  end

  @doc """
  Returns the most recent measurement entry for a given pool.

  ## Parameters

    * `pool_id` - The ID of the pool

  ## Example

      iex> PoolProj.Query.get_latest_measurement_by_pool_id(1)
      %Measurement{date: ~D[2024-03-10], ...}

  Returns `nil` if no measurement exists for the pool.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Applies ordering and limit to find the most recent record.
  @since 2025-04-07
  """
  def get_latest_measurement_by_pool_id(pool_id) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id,
      order_by: [desc: m.date],
      limit: 1,
      select: m
    )
    |> Repo.one()
  end

  @doc """
  Returns the analysis record associated with a specific measurement ID.

  ## Parameters

    * `measurement_id` - The ID of the measurement

  ## Example

      iex> PoolProj.Query.get_analysis_by_measurement_id(5)
      %Analysis{}

  Returns `nil` if no analysis is found for the measurement ID provided.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Direct lookup using foreign key.
  @since 2025-04-07
  """
  def get_analysis_by_measurement_id(measurement_id) do
    from(a in Analysis,
      where: a.measurement_id == ^measurement_id,
      select: a
    )
    |> Repo.one()
  end

  @doc """
  Returns all pools that match a given location string.

  ## Parameters

    * `location` - A string representing the pool's location

  ## Example

      iex> PoolProj.Query.get_pools_by_location("Phoenix")
      [%Pool{}, ...]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Executes a simple filter on the `location` field.
  @since 2025-04-07
  """
  def get_pools_by_location(location) do
    from(p in Pool,
      where: p.location == ^location,
      select: p
    )
    |> Repo.all()
  end

  @doc """
  Returns all measurements for a specific pool within a given date range.

  ## Parameters

    * `pool_id` - The pool ID
    * `start_date` - Beginning of the date range (`~D[YYYY-MM-DD]`)
    * `end_date` - End of the date range (`~D[YYYY-MM-DD]`)

  ## Example

      iex> PoolProj.Query.get_measurements_by_pool_id_and_date_range(2, ~D[2024-01-01], ~D[2024-02-01])
      [%Measurement{}, ...]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium - Combines multiple filters including range comparisons.
  @since 2025-04-07
  """
  def get_measurements_by_pool_id_and_date_range(pool_id, start_date, end_date) do
    from(m in Measurement,
      where: m.pool_id == ^pool_id and m.date >= ^start_date and m.date <= ^end_date,
      select: m
    )
    |> Repo.all()
  end

  @doc """
  Returns all analysis records that match a specific status.

  ## Parameters

    * `status` - One of `"ok"`, `"warning"`, or `"critical"`

  ## Example

      iex> PoolProj.Query.get_analysis_by_status("critical")
      [%Analysis{}, ...]

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Simple filter by status field.
  @since 2025-04-07
  """
  def get_analysis_by_status(status) do
    from(a in Analysis,
      where: a.status == ^status,
      select: a
    )
    |> Repo.all()
  end

  @doc """
  Returns the total number of pools in the database.

  ## Example

      iex> PoolProj.Query.count_pools()
      25

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Uses `count/1` aggregation.
  @since 2025-04-07
  """
  def count_pools do
    from(p in Pool, select: count(p.id))
    |> Repo.one()
  end

  @doc """
  Returns the average volume of all pools in the database.

  ## Example

      iex> PoolProj.Query.average_pool_volume()
      10200.75

  Returns `nil` if there are no pools in the database.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Uses `avg/1` aggregation.
  @since 2025-04-07
  """
  def average_pool_volume do
    from(p in Pool, select: avg(p.volume))
    |> Repo.one()
  end

  @doc """
  Deletes a pool and all of its associated measurements and analysis records.

  ## Parameters

    * `pool_id` - The ID of the pool to delete.

  ## Returns

    * A tuple with counts of deleted rows: `{analysis_count, measurement_count, pool_count}`
  """
  def delete_pool_by_id(pool_id) do
    analysis_count =
      Repo.delete_all(
        from a in Analysis,
          join: m in Measurement,
          on: a.measurement_id == m.id,
          where: m.pool_id == ^pool_id
      )

    measurement_count =
      Repo.delete_all(
        from m in Measurement,
          where: m.pool_id == ^pool_id
      )

    pool_count =
      Repo.delete_all(
        from p in Pool,
          where: p.id == ^pool_id
      )

    {analysis_count, measurement_count, pool_count}
  end

@doc """
Prints a readable summary of all pools in the system.

Includes pool ID, volume, and decoded location info.
"""
def print_all_pools do
  Repo.all(Pool)
  |> Enum.each(fn pool ->
    location =
      case Jason.decode(pool.location) do
        {:ok, loc} -> "#{loc["city"]}, #{loc["state"]}, #{loc["country"]} (ID: #{loc["city_id"]})"
        _ -> pool.location
      end

    IO.puts("""
     Pool ID: #{pool.id}
     Location: #{location}
     Volume: #{pool.volume || "unknown"} L
     Created: #{pool.inserted_at}
    -----------------------------
    """)
  end)
end

@doc """
Displays all measurements for a given pool ID in a readable table-like format.
"""
def print_measurements_for_pool(pool_id) do
  measurements = get_measurements_by_pool_id(pool_id)

  if Enum.empty?(measurements) do
    IO.puts("❌ No measurements found for pool #{pool_id}")
  else
    IO.puts("""
    📊 Measurements for Pool #{pool_id}
    ---------------------------------------------------------------------------
    |     Date     |  FC  |  CC  |  pH  |   TA   |   CH   |
    ---------------------------------------------------------------------------
    """)

    Enum.each(measurements, fn m ->
      IO.puts(
        "| #{String.pad_trailing("#{m.date}", 12)}" <>
        "| #{pad_float(m.free_chlorine)}" <>
        "| #{pad_float(m.combined_chlorine)}" <>
        "| #{pad_float(m.pH)}" <>
        "| #{pad_float(m.total_alkalinity)}" <>
        "| #{pad_float(m.calcium_hardness)} |"
      )
    end)

    IO.puts("---------------------------------------------------------------------------\n")
  end
end

defp pad_float(nil), do: "  -- "
defp pad_float(val), do: String.pad_leading(:erlang.float_to_binary(val, decimals: 2), 6)

@doc """
Prints the most recent measurement and associated analysis for a pool.
"""
def print_latest_snapshot(pool_id) do
  case get_latest_measurement_by_pool_id(pool_id) do
    nil ->
      IO.puts("❌ No measurements found for pool #{pool_id}")

    m ->
      IO.puts("""
      ✅ Latest Measurement (#{m.date}):
        - Free Chlorine: #{m.free_chlorine}
        - Combined Chlorine: #{m.combined_chlorine}
        - pH: #{m.pH}
        - TA: #{m.total_alkalinity}
        - CH: #{m.calcium_hardness}
      """)

      case get_analysis_by_measurement_id(m.id) do
        nil ->
          IO.puts("⚠️  No analysis found for this measurement.")

        a ->
          IO.puts("""
          📊 Analysis:
            - Status: #{a.status}
            - Recommendation:
              #{a.recommendation}
          """)
      end
  end
end


end
