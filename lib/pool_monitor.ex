defmodule PoolMonitor do
  import Ecto.Query
  alias PoolProj.{Repo, Pool, Measurement, Analysis}
  alias PoolSimulator
  alias PoolGenerator
  alias PoolChemistryChecker
  alias PoolDataAdjuster

  @initial_date ~D[2024-01-01]

  @moduledoc """
  Provides functions to simulate and monitor pool chemistry levels, run analyses,
  and persist results to the database.

  This module manages the lifecycle of pool data by generating initial conditions,
  simulating daily changes, analyzing chemical levels, and storing recommendations.

  ## Features

    * Initializes pools with simulated data
    * Analyzes pool chemistry for safety and maintenance
    * Runs daily simulations on existing pools

  ## Example

  To start the system with initial pool creation:

      PoolMonitor.run_initial(15)

  To continue running the system without creating new pools:

      PoolMonitor.run(10_000)

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium
  @since 2025-04-07
  """

  @doc """
  Starts the pool monitoring simulation without creating new pools.

  This function starts an infinite loop that simulates daily chemistry data updates for all existing pools.

  ## Parameters

    * `interval` - Time (in milliseconds) between simulation runs (default: `5_000`)

  ## Example

      PoolMonitor.run(10_000)

  Begins recurring daily simulations every 10 seconds on existing pools only (no new pools are created).

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Starts the continuous simulation loop for all existing pools.
  @since 2025-04-07
  """
  def run(interval \\ 5_000) do
    loop(interval)
  end

  @doc """
  Initializes the system by generating and inserting a specified number of new pools (default: 10),
  along with their initial measurements and analysis data.

  Once setup is complete for all pools, it enters a recurring loop to simulate daily data changes.

  ## Parameters

    * `pool_count` - The number of pools to create and initialize (default: `10`)

  ## Example

      PoolMonitor.run_initial(5)

  Creates and sets up 5 new pools with simulated chemistry data.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium - Iterates over pool creation and sets up each with initial simulated data and analysis.
  @since 2025-04-07
  """
  def run_initial(pool_count \\ 10) do
    1..pool_count
    |> Enum.each(fn _ ->
      # Create a pool
      attrs = PoolGenerator.generate_pool()

      # If pool is added to db
      with {:ok, pool} <- Repo.insert(Pool.changeset(%Pool{}, attrs)),
          # Create and add measurements to measurements db
           measurement_data <- create_initial_measurement(pool),
           {:ok, measurement} <- add_measurement_to_db(measurement_data),

           # Create and add analysis to analysis table
           analysis_data <- analyze_pool_measurement(measurement),
           {:ok, _analysis} <- add_analysis_to_db(analysis_data) do
        IO.puts("Setup complete for pool #{pool.id}")
      else
        {:error, reason} ->
          IO.inspect(reason, label: "Failed during pool setup")
      end
    end)

    loop(5_000)
  end

  @doc """
  Generates an initial measurement map for a given pool, merging simulated chemistry
  data with pool-specific metadata like `pool_id` and the `@initial_date`.

  ## Parameters

    * `pool` - The `%Pool{}` struct representing the pool to generate data for

  ## Returns

    * A map containing the simulated measurement values with the pool ID and date

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Performs simple map merging of static and simulated values.
  @since 2025-04-07
  """
  def create_initial_measurement(pool) do
    data = PoolSimulator.generate_initial_data()

    Map.merge(data, %{
      pool_id: pool.id,
      date: @initial_date
    })
  end

  @doc """
  Inserts a pool measurement into the database using an Ecto changeset.

  ## Parameters

    * `measurement_data` - A map containing measurement values

  ## Returns

    * `{:ok, %Measurement{}}` on success
    * `{:error, changeset}` on failure (e.g. validation error)

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Wraps standard Ecto insert for a single struct.
  @since 2025-04-07
  """
  def add_measurement_to_db(measurement_data) do
    changeset = Measurement.changeset(%Measurement{}, measurement_data)
    Repo.insert(changeset)
  end

  @doc """
  Analyzes a pool's measurement data to determine chemical status and maintenance
  recommendations based on thresholds.

  ## Parameters

    * `measurement` - The `%Measurement{}` struct to be analyzed

  ## Returns

    * A map containing `:measurement_id`, `:recommendation`, and `:status` fields

  > Uses the `PoolChemistryChecker` module for chemical level validation and summarization.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium - Combines pool and measurement data and performs external analysis.
  @since 2025-04-07
  """
  def analyze_pool_measurement(measurement) do
    pool = Repo.get!(Pool, measurement.pool_id)

    pool_data = %{
      pool_volume: pool.volume,
      free_chlorine: measurement.free_chlorine,
      combined_chlorine: measurement.combined_chlorine,
      pH: measurement.pH,
      total_alkalinity: measurement.total_alkalinity,
      calcium_hardness: measurement.calcium_hardness
    }

    results = PoolChemistryChecker.check_levels(pool_data)

    %{
      measurement_id: measurement.id,
      recommendation: format_recommendations(results),
      status: summarize_status(results)
    }
  end

  @doc """
  Inserts an analysis entry into the database using an Ecto changeset.

  ## Parameters

    * `analysis_data` - A map containing analysis results and recommendation status

  ## Returns

    * `{:ok, %Analysis{}}` on success
    * `{:error, changeset}` on failure (e.g. validation issue in the analysis struct)

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Simple Ecto insert logic for analysis struct.
  @since 2025-04-07
  """
  def add_analysis_to_db(analysis_data) do
    changeset = Analysis.changeset(%Analysis{}, analysis_data)
    Repo.insert(changeset)
  end

  @doc """
  Formats a list of chemical check results into a user-friendly, space-separated string
  of recommendations.

  ## Parameters

    * `results` - A map returned by `PoolChemistryChecker.check_levels/1`

  ## Returns

    * A single string containing all recommendation messages concatenated together

  @example

      format_recommendations(%{pH: {:low, "Raise pH"}})
      #=> "Raise pH"

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Performs simple value extraction and string concatenation.
  @since 2025-04-07
  """
  def format_recommendations(results) do
    results
    |> Map.values()
    |> Enum.map(fn
      {:ok, msg} -> msg
      {_level, msg} -> msg
    end)
    |> Enum.join(" ")
  end

  @doc """
  Summarizes overall chemical status for a pool based on level severity.

  ## Parameters

    * `results` - A map of chemical level results

  ## Returns

    * `"critical"` if any level is `:high`
    * `"warning"` if any level is `:low`
    * `"ok"` if all are within acceptable range

  @example

      summarize_status(%{pH: {:low, "Too low"}})
      #=> "warning"

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Performs simple pattern matching on level statuses.
  @since 2025-04-07
  """
  def summarize_status(results) do
    cond do
      Enum.any?(results, fn {_, {:high, _}} -> true; _ -> false end) -> "critical"
      Enum.any?(results, fn {_, {:low, _}} -> true; _ -> false end) -> "warning"
      true -> "ok"
    end
  end

  @doc """
  Performs a one-time simulation cycle across all pools in the database.

  For each pool:
    * Retrieves the latest measurement
    * Adjusts chemistry values
    * Inserts new measurement
    * Analyzes the result
    * Stores new analysis

  Logs simulation progress or errors to the console.

  ## Returns

    * `:ok` after all pools are processed (side effects only)

  @example

      PoolMonitor.run_once()

  Runs one day’s simulation without looping continuously.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Medium - Orchestrates a multi-step data pipeline per pool.
  @since 2025-04-07
  """
  def run_once do
    IO.puts("🚀 Running daily simulation...")

    Repo.all(Pool)
    |> Enum.each(fn pool ->
      case get_latest_measurement(pool.id) do
        nil ->
          IO.warn("⚠️  No measurements found for pool #{pool.id}, skipping simulation.")

        {:ok, latest} ->
          with adjusted_data <- PoolDataAdjuster.adjust(latest),
               {:ok, new_measurement} <- insert_adjusted_measurement(pool, latest, adjusted_data),
               analysis_data <- analyze_pool_measurement(new_measurement),
               {:ok, _} <- add_analysis_to_db(analysis_data) do
            IO.puts("✅ Simulated day for pool #{pool.id}")
          else
            {:error, reason} ->
              IO.inspect(reason, label: "Simulation failed for pool #{pool.id}")
          end

        {:error, reason} ->
          IO.inspect(reason, label: "Failed to get latest measurement for pool #{pool.id}")
      end
    end)
  end


  @doc """
  Fetches the most recent measurement for a given pool ID.

  ## Parameters

    * `pool_id` - ID of the pool to retrieve data for

  ## Returns

    * `{:ok, %Measurement{}}` if found
    * `{:error, :no_measurement_found}` if none exist for the pool

  @example

      get_latest_measurement(1)
      #=> {:ok, %Measurement{}}

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Executes a filtered, sorted Ecto query.
  @since 2025-04-07
  """
  def get_latest_measurement(pool_id) do
    case Repo.one(
           from(m in Measurement,
             where: m.pool_id == ^pool_id,
             order_by: [desc: m.date],
             limit: 1
           )
         ) do
      nil -> {:error, :no_measurement_found}
      measurement -> {:ok, measurement}
    end
  end

  @doc """
  Inserts a new adjusted measurement record for a pool based on previous measurement data.

  ## Parameters

    * `pool` - The pool struct for which data is being inserted
    * `latest_measurement` - The most recent `%Measurement{}` used as a reference
    * `adjusted_data` - A map of adjusted chemistry values

  ## Returns

    * `{:ok, %Measurement{}}` on success
    * `{:error, changeset}` on failure (e.g. invalid data)

  @example

      insert_adjusted_measurement(pool, measurement, %{pH: 7.2, ...})

  Creates a new daily measurement with incremented date and adjusted chemistry values.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Wraps a date increment and Ecto insert call.
  @since 2025-04-07
  """
  def insert_adjusted_measurement(pool, latest_measurement, adjusted_data) do
    changes = Map.merge(adjusted_data, %{
      pool_id: pool.id,
      date: Date.add(latest_measurement.date, 1)
    })

    Repo.insert(Measurement.changeset(%Measurement{}, changes))
  end

  @doc """
  Internal loop function that continuously runs daily simulations at a specified interval.

  This function is recursively called to keep the simulation going indefinitely.

  ## Parameters

    * `interval` - Time in milliseconds to wait between simulation cycles

  > Note: This function is not intended to be called directly by users.

  @example

      PoolMonitor.loop(5000)

  Runs daily simulations every 5 seconds in a loop until manually stopped.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Recursively loops and triggers daily simulation logic.
  @since 2025-04-07
  """
  def loop(interval) do
    :timer.sleep(interval)
    run_once()
    loop(interval)
  end
end
