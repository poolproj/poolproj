defmodule PoolDataAdjusterTest do
  use ExUnit.Case

  defmodule PoolData do
    defstruct [
      :pH,
      :free_chlorine,
      :total_alkalinity,
      :calcium_hardness,
      :combined_chlorine
    ]
  end


  describe "adjust_parameter/2" do
    test "adjusts value up when below min" do
      param = :pH
      value = 6.3

      result = PoolDataAdjuster.adjust_parameter(param, value)

      assert is_float(result)
      assert result > value
    end

    test "adjusts value down when above max" do
      param = :total_alkalinity
      value = 130

      result = PoolDataAdjuster.adjust_parameter(param, value)

      assert is_float(result) or is_integer(result)
      assert result < value
    end

    test "adjusts value randomly within range when already in range" do
      param = :free_chlorine
      value = 3.0

      result = PoolDataAdjuster.adjust_parameter(param, value)

      assert is_float(result)
      assert result >= 2.0
      assert result <= 4.0
    end

    test "returns original value for unknown parameter" do
      param = :unknown_chemical
      value = 5.0

      result = PoolDataAdjuster.adjust_parameter(param, value)

      assert result == value
    end
  end

  describe "adjust/1" do
    test "adjusts all known chemicals toward ideal ranges" do
      input = %PoolData{
        pH: 6.8,
        free_chlorine: 1.2,
        total_alkalinity: 130,
        calcium_hardness: 150,
        combined_chlorine: 1.0
      }


      result = PoolDataAdjuster.adjust(input)

      assert Map.has_key?(result, :pH)
      assert Map.has_key?(result, :free_chlorine)
      assert Map.has_key?(result, :total_alkalinity)
      assert Map.has_key?(result, :calcium_hardness)
      assert Map.has_key?(result, :combined_chlorine)

      assert result.pH > input.pH
      assert result.free_chlorine > input.free_chlorine
      assert result.total_alkalinity < input.total_alkalinity
      assert result.calcium_hardness > input.calcium_hardness
      assert result.combined_chlorine < input.combined_chlorine
    end

  end
end
