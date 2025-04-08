defmodule PoolProj.QueryTest do
  use ExUnit.Case

  alias PoolProj.Query
  alias PoolProj.{Pool, Measurement, Analysis}

  setup do
    :meck.new(Repo, [:passthrough])
    on_exit(fn -> :meck.unload(Repo) end)
    :ok
  end

  describe "get_pool_ids/0_" do
    test "returns a list of pool IDs_" do
      :meck.expect(Repo, :all, fn _ -> [1, 2, 3] end)

      result = Query.get_pool_ids()

      assert is_list(result)
      assert Enum.all?(result, &is_integer/1)
      assert result == [1, 2, 3]
    end
  end

  describe "get_analysis_by_pool_id/1_" do
    test "returns analysis list for a valid pool ID_" do
      :meck.expect(Repo, :all, fn _ -> [%Analysis{id: 1}, %Analysis{id: 2}] end)

      result = Query.get_analysis_by_pool_id(1)

      assert is_list(result)
      assert Enum.all?(result, &match?(%Analysis{}, &1))
      assert Enum.count(result) == 2
    end

    test "returns empty list for pool ID with no analysis records_" do
      :meck.expect(Repo, :all, fn _ -> [] end)

      result = Query.get_analysis_by_pool_id(999)

      assert is_list(result)
      assert result == []
    end
  end

  describe "get_measurements_by_pool_id/1_" do
    test "returns measurements for valid pool ID_" do
      :meck.expect(Repo, :all, fn _ -> [%Measurement{id: 1}, %Measurement{id: 2}] end)

      result = Query.get_measurements_by_pool_id(2)

      assert is_list(result)
      assert Enum.all?(result, &match?(%Measurement{}, &1))
      assert Enum.count(result) == 2
    end

    test "returns empty list when no measurements found_" do
      :meck.expect(Repo, :all, fn _ -> [] end)

      result = Query.get_measurements_by_pool_id(404)

      assert is_list(result)
      assert result == []
    end
  end

  describe "get_latest_measurement_by_pool_id/1_" do
    test "returns the latest measurement for a pool_" do
      :meck.expect(Repo, :one, fn _ -> %Measurement{id: 10, date: ~D[2024-03-10]} end)

      result = Query.get_latest_measurement_by_pool_id(1)

      assert match?(%Measurement{}, result)
      assert result.date == ~D[2024-03-10]
    end

    test "returns nil if no measurements exist for pool_" do
      :meck.expect(Repo, :one, fn _ -> nil end)

      result = Query.get_latest_measurement_by_pool_id(1)

      assert is_nil(result)
    end
  end

  describe "get_analysis_by_measurement_id/1_" do
    test "returns analysis record for a valid measurement ID_" do
      :meck.expect(Repo, :one, fn _ -> %Analysis{id: 5} end)

      result = Query.get_analysis_by_measurement_id(5)

      assert match?(%Analysis{}, result)
      assert result.id == 5
    end

    test "returns nil when no analysis is associated with the measurement ID_" do
      :meck.expect(Repo, :one, fn _ -> nil end)

      result = Query.get_analysis_by_measurement_id(404)

      assert is_nil(result)
    end
  end

  describe "count_pools/0_" do
    test "returns the total number of pools_" do
      :meck.expect(Repo, :one, fn _ -> 42 end)

      result = Query.count_pools()

      assert is_integer(result)
      assert result == 42
    end
  end

  describe "average_pool_volume/0_" do
    test "returns average pool volume_" do
      :meck.expect(Repo, :one, fn _ -> 10800.5 end)

      result = Query.average_pool_volume()

      assert is_float(result)
      assert result == 10800.5
    end

    test "returns nil when no pools exist_" do
      :meck.expect(Repo, :one, fn _ -> nil end)

      result = Query.average_pool_volume()

      assert is_nil(result)
    end
  end
end
