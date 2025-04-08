defmodule PoolGeneratorTest do
  use ExUnit.Case

  test "generate_pool returns a map with location and volume keys" do
    pool = PoolGenerator.generate_pool()

    assert is_map(pool)
    assert Map.has_key?(pool, :location)
    assert Map.has_key?(pool, :volume)
  end

  test "location is a JSON string" do
    pool = PoolGenerator.generate_pool()

    assert is_binary(pool.location)

    decoded =
      case Jason.decode(pool.location) do
        {:ok, result} -> result
        _ -> flunk("location is not valid JSON")
      end

    assert is_map(decoded) or is_binary(decoded)
  end

  test "volume is within expected range" do
    for _ <- 1..20 do
      pool = PoolGenerator.generate_pool()
      assert pool.volume >= 10_000
      assert pool.volume <= 30_000
    end
  end

  test "generate_pool produces different results across calls" do
    pool1 = PoolGenerator.generate_pool()
    pool2 = PoolGenerator.generate_pool()

    refute pool1 == pool2
  end
end
