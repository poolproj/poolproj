defmodule PoolMonitor do
  import Ecto.Query
  alias PoolProj.{Repo, Pool, Measurement, Analysis}
  alias PoolSimulator
  alias PoolGenerator
  alias PoolChemistryChecker
  alias PoolDataAdjuster



  @initial_date ~D[2024-01-01]

  # Sets up x pools (default = 10) and starts the program on all pools (new + existing)
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
        IO.puts("✅ Setup complete for pool #{pool.id}")
      else
        {:error, reason} ->
          IO.inspect(reason, label: "Failed during pool setup")
      end
    end)

    loop(5_000)
  end




  defp create_initial_measurement(pool) do
    data = PoolSimulator.generate_initial_data()

    Map.merge(data, %{
      pool_id: pool.id,
      date: @initial_date
    })
  end

  defp add_measurement_to_db(measurement_data) do
    changeset = Measurement.changeset(%Measurement{}, measurement_data)
    Repo.insert(changeset)
  end

  defp analyze_pool_measurement(measurement) do
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

  defp add_analysis_to_db(analysis_data) do
    changeset = Analysis.changeset(%Analysis{}, analysis_data)
    Repo.insert(changeset)
  end

  defp format_recommendations(results) do
    results
    |> Map.values()
    |> Enum.map(fn
      {:ok, msg} -> msg
      {_level, msg} -> msg
    end)
    |> Enum.join(" ")
  end

  defp summarize_status(results) do
    cond do
      Enum.any?(results, fn {_, {:high, _}} -> true; _ -> false end) -> "critical"
      Enum.any?(results, fn {_, {:low, _}} -> true; _ -> false end) -> "warning"
      true -> "ok"
    end
  end


  # This starts the program on the existing pools, but does not add more pools.
  def run(interval \\ 5_000) do
    loop(interval)
  end

  defp run_once do
    IO.puts("🚀 Running daily simulation...")

    Repo.all(Pool)
    |> Enum.each(fn pool ->
      with {:ok, latest} <- get_latest_measurement(pool.id),
           adjusted_data <- PoolDataAdjuster.adjust(latest),
           {:ok, new_measurement} <- insert_adjusted_measurement(pool, latest, adjusted_data),
           analysis_data <- analyze_pool_measurement(new_measurement),
           {:ok, _} <- add_analysis_to_db(analysis_data) do
        IO.puts("✅ Simulated day for pool #{pool.id}")
      else
        {:error, reason} ->
          IO.inspect(reason, label: "❌ Simulation failed for pool #{pool.id}")
      end
    end)
  end

  defp get_latest_measurement(pool_id) do
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


  defp insert_adjusted_measurement(pool, latest_measurement, adjusted_data) do
    changes = Map.merge(adjusted_data, %{
      pool_id: pool.id,
      date: Date.add(latest_measurement.date, 1)
    })

    Repo.insert(Measurement.changeset(%Measurement{}, changes))
  end

  def loop(interval) do
    :timer.sleep(interval)
    run_once()
    loop(interval)
  end
end
