
# track downtime for swimming pools
# Particularly focused on tracking pH adjustment periods
# Parameters:
# - pool_id: Unique identifier for the pool
# - current_ph: Current pH value of the pool
# - target_ph: Target pH value to achieve
# - start_time: When the adjustment begins (DateTime)
# - end_time: Estimated completion time (DateTime)

defmodule PoolDowntime do
  # Factory Method
  def schedule_ph_adjustment(pool_id, current_ph, target_ph, start_time, end_time) do
    # validate time range
    if DateTime.compare(end_time, start_time) == :lt do
      {:error, "End time cannot be before start time"}
    else

    end
    # calculate estimated duration in min
    duration_seconds = DateTime.diff(end_time, start_time)
    # trans the sec to min
    duration_minutes = div(duration_seconds, 60)
    # create downtime record    create likes hashmap
    downtime = %{
      pool_id: pool_id,
      adjustment_type: :ph,
      current_value: current_ph,
      target_value: target_ph,
      adjustment_size: Float.round(abs(target_ph - current_ph), 2),
      start_time: start_time,
      end_time: end_time,
      duration_minutes: duration_minutes,
      status: :scheduled
    }
    # save it for database
    {:ok, downtime}

  end



  def start_ph_adjustment(downtime_id) do
    {:ok, %{downtime_id: downtime_id, status: :in_progress, started_at: DateTime.utc_now()}}
  end

  @spec complete_ph_adjustment(any(), any()) ::
          {:ok,
           %{
             completed_at: DateTime.t(),
             downtime_id: any(),
             final_value: any(),
             status: :completed
           }}
  def complete_ph_adjustment(downtime_id, final_ph) do

    now = DateTime.utc_now()
    {:ok, %{
      downtime_id: downtime_id,
      status: :completed,
      completed_at: now,
      final_value: final_ph
    }}
  end


  # memoization
  def estimate_ph_adjustment_time(current_ph, target_ph, pool_volume) do

    # Base time + additional time based on volume and difference magnitude
    ph_difference = abs(target_ph - current_ph)
    base_minutes = 30
    volume_factor = pool_volume / 10_000
    adjustment_factor = ph_difference * 60

    estimated_minutes = round(base_minutes + (volume_factor * adjustment_factor))

    # Return estimated downtime in minutes
    estimated_minutes

  end

  @doc """
  Generate a report of upcoming and past pH adjustments for a pool.
  """
  def list_ph_adjustments(pool_id) do
    #mock response should return database

  {:ok, [
    %{
      pool_id: pool_id,
      adjustment_type: :ph,
      current_value: 7.2,
      target_value: 7.5,
      start_time: ~U[2025-03-26 08:00:00Z],
      end_time: ~U[2025-03-26 10:00:00Z],
      status: :completed
    },
    %{
      pool_id: pool_id,
      adjustment_type: :ph,
      current_value: 7.8,
      target_value: 7.5,
      start_time: ~U[2025-03-28 08:00:00Z],
      end_time: ~U[2025-03-28 09:30:00Z],
      status: :scheduled
    }
  ]}

  end

end
