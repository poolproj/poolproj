defmodule PoolGeneratorTest do
  use ExUnit.Case
  alias PoolGenerator

  describe "generate_pool/0" do
    test "returns a map with location and volume keys" do
      pool = PoolGenerator.generate_pool()

      assert is_map(pool)
      assert Map.has_key?(pool, :location)
      assert Map.has_key?(pool, :volume)
    end

    test "location is a valid JSON string representing a city" do
      pool = PoolGenerator.generate_pool()

      assert is_binary(pool.location)

      decoded = Jason.decode!(pool.location)
      assert is_map(decoded)

      assert decoded["city"] |> is_binary()
      assert decoded["country"] |> is_binary()
      assert decoded["state"] |> is_binary()
      assert is_integer(decoded["city_id"])
    end

    test "volume is within expected range" do
      for _ <- 1..10 do
        pool = PoolGenerator.generate_pool()
        assert pool.volume >= 10_000
        assert pool.volume <= 30_000
      end
    end
  end
end
