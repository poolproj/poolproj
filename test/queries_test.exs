defmodule PoolProj.QueryTest do
  use ExUnit.Case
  # mix test test/queries_test.exs

  alias PoolProj.{Repo, Pool, Measurement, Analysis, Query}

  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  test "get_pool_ids returns all pool ids" do
    pool1 = Repo.insert!(%Pool{location: "Miami", volume: 10000})
    pool2 = Repo.insert!(%Pool{location: "Phoenix", volume: 12000})

    result = Query.get_pool_ids()
    assert pool1.id in result
    assert pool2.id in result
  end

  test "get_analysis_by_pool_id returns analysis records for a given pool" do
    pool = Repo.insert!(%Pool{location: "LA", volume: 8000})
    m = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-03-01]})
    a = Repo.insert!(%Analysis{measurement_id: m.id, status: "ok", recommendation: "Stable"})

    result = Query.get_analysis_by_pool_id(pool.id)
    assert length(result) == 1
    assert hd(result).id == a.id
  end

  test "get_measurements_by_pool_id returns measurements for pool" do
    pool = Repo.insert!(%Pool{})
    m1 = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-01-01]})
    m2 = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-01-02]})

    result = Query.get_measurements_by_pool_id(pool.id)
    assert Enum.map(result, & &1.id) |> Enum.sort() == [m1.id, m2.id] |> Enum.sort()
  end

  test "get_latest_measurement_by_pool_id returns most recent measurement" do
    pool = Repo.insert!(%Pool{})
    _old = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-01-01]})
    latest = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-04-01]})

    result = Query.get_latest_measurement_by_pool_id(pool.id)
    assert result.id == latest.id
  end

  test "get_analysis_by_measurement_id returns correct analysis" do
    m = Repo.insert!(%Measurement{})
    a = Repo.insert!(%Analysis{measurement_id: m.id, status: "warning", recommendation: "Add chlorine"})

    result = Query.get_analysis_by_measurement_id(m.id)
    assert result.id == a.id
  end

  test "get_pools_by_location filters by location" do
    p1 = Repo.insert!(%Pool{location: "Houston"})
    _p2 = Repo.insert!(%Pool{location: "Chicago"})

    result = Query.get_pools_by_location("Houston")
    assert length(result) == 1
    assert hd(result).id == p1.id
  end

  test "get_measurements_by_pool_id_and_date_range returns filtered results" do
    pool = Repo.insert!(%Pool{})
    _m1 = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-01-01]})
    m2 = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-02-01]})
    _m3 = Repo.insert!(%Measurement{pool_id: pool.id, date: ~D[2024-03-01]})

    result = Query.get_measurements_by_pool_id_and_date_range(pool.id, ~D[2024-01-15], ~D[2024-02-15])
    assert length(result) == 1
    assert hd(result).id == m2.id
  end

  test "get_analysis_by_status returns all matching analysis entries" do
    m = Repo.insert!(%Measurement{})
    a1 = Repo.insert!(%Analysis{measurement_id: m.id, status: "critical"})
    _a2 = Repo.insert!(%Analysis{measurement_id: m.id, status: "ok"})

    result = Query.get_analysis_by_status("critical")
    assert length(result) == 1
    assert hd(result).id == a1.id
  end

  test "count_pools returns total pool count" do
    Repo.insert!(%Pool{})
    Repo.insert!(%Pool{})
    assert Query.count_pools() >= 2
  end

  test "average_pool_volume returns the average" do
    Repo.insert!(%Pool{volume: 10000})
    Repo.insert!(%Pool{volume: 20000})
    assert Query.average_pool_volume() == 15000.0
  end
end
