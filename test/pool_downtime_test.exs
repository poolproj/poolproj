defmodule PoolDowntimeTest do
  use ExUnit.Case
  alias PoolDowntime

  setup do

    PoolDowntime.init()
    :ok
  end

  test "schedules a valid pH adjustment" do
    start_time = DateTime.utc_now()
    end_time = DateTime.add(start_time, 3600)

    {:ok, record} = PoolDowntime.schedule_ph_adjustment("pool001", 7.0, 7.4, start_time, end_time)

    assert record.pool_id == "pool001"
    assert record.duration_minutes == 60
    assert record.status == :scheduled
    assert record.adjustment_size == 0.4
  end

  test "rejects pH adjustment with end_time before start_time" do
    start_time = DateTime.utc_now()
    end_time = DateTime.add(start_time, -3600)

    result = PoolDowntime.schedule_ph_adjustment("pool002", 7.2, 7.5, start_time, end_time)

    assert result == {:error, "End time cannot be before start time"}
  end

  test "completes a scheduled adjustment" do
    start_time = DateTime.utc_now()
    end_time = DateTime.add(start_time, 1800)
    {:ok, _record} = PoolDowntime.schedule_ph_adjustment("pool003", 7.6, 7.2, start_time, end_time)

    {:ok, completed} = PoolDowntime.complete_ph_adjustment("pool003", 7.2)

    assert completed.status == :completed
    assert completed.final_value == 7.2
    assert Map.has_key?(completed, :completed_at)
  end

  test "estimates pH adjustment time correctly" do
    time = PoolDowntime.estimate_ph_adjustment_time(7.0, 7.5, 20_000)

    assert is_integer(time)
    assert time > 0
  end
end

has context menu
