
# track downtime for swimming pools
# Particularly focused on tracking pH adjustment periods
# Parameters:
# - pool_id: Unique identifier for the pool
# - current_ph: Current pH value of the pool
# - target_ph: Target pH value to achieve
# - start_time: When the adjustment begins (DateTime)
# - end_time: Estimated completion time (DateTime)

defmodule Event do
  defstruct [:event_id, :event_type, :entity_id, :payload, :timestamp]
end

defmodule Downtime do
  defstruct [
    :pool_id,
    :adjustment_type,
    :current_value,
    :target_value,
    :adjustment_size,
    :start_time,
    :end_time,
    :duration_minutes,
    :status
  ]
end

defmodule PoolDowntime do
  @table :downtime_table

  # initial ETS
  def init do
    unless :ets.whereis(@table) != :undefined do
      :ets.new(@table, [:named_table, :public, :set])
    end
  end

  # factory pH adj
  def schedule_ph_adjustment(pool_id, current_ph, target_ph, start_time, end_time) do
    if DateTime.compare(end_time, start_time) == :lt do
      {:error, "End time cannot be before start time"}
    else
      duration_minutes = div(DateTime.diff(end_time, start_time), 60)
      downtime = %Downtime{
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

      # store
      :ets.insert(@table, {pool_id, downtime})

      # event notification
      emit_event("ph_adjustment_scheduled", Map.from_struct(downtime))

      {:ok, downtime}
    end
  end

  def start_ph_adjustment(pool_id) do
    case :ets.lookup(@table, pool_id) do
      [{^pool_id, downtime}] ->
        updated = %{downtime | status: :in_progress}
        :ets.insert(@table, {pool_id, updated})
        emit_event("ph_adjustment_started", Map.from_struct(updated))
        {:ok, updated}

      [] ->
        {:error, "Downtime record not found"}
    end
  end

  def complete_ph_adjustment(pool_id, final_ph) do
    case :ets.lookup(@table, pool_id) do
      [{^pool_id, downtime}] ->
        updated = %{
          downtime |
          status: :completed,
          final_value: final_ph,
          completed_at: DateTime.utc_now()
        }

        :ets.insert(@table, {pool_id, updated})
        emit_event("ph_adjustment_completed", Map.from_struct(updated))
        {:ok, updated}

      [] ->
        {:error, "Downtime record not found"}
    end
  end

  # adj time
  def estimate_ph_adjustment_time(current_ph, target_ph, pool_volume) do
    ph_diff = abs(target_ph - current_ph)
    base_minutes = 30
    volume_factor = pool_volume / 10_000
    adjustment_factor = ph_diff * 60

    round(base_minutes + volume_factor * adjustment_factor)
  end

  # search record  from ETS
  def list_ph_adjustments(pool_id) do
    case :ets.lookup(@table, pool_id) do
      [{^pool_id, downtime}] ->
        {:ok, [downtime]}

      [] ->
        {:ok, []}
    end
  end

  # mock
  defp emit_event(event_type, payload) do
    event = %Event{
      event_id: UUID.uuid4(),
      event_type: event_type,
      entity_id: payload[:pool_id],
      payload: payload,
      timestamp: System.system_time(:millisecond)
    }

    IO.inspect(event, label: " Emitted Event")
    :ok
  end
end
