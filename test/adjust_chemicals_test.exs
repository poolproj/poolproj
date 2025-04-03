defmodule AdjustChemicalsTest do
  use ExUnit.Case

  alias AdjustChemicals

  setup do
    # Ensures deterministic behavior from ":rand" for reproducible test results
    :rand.seed(:exsplus, {101, 102, 103})
    :ok
  end

  describe "adjust_all_parameters/1" do
    @doc """
    Verifies that parameters within the desired range are only adjusted a little bit.
    """
    test "returns slightly adjusted values when all inputs are within range_" do
      input = %{
        free_chlorine: 3.0,
        combined_chlorine: 0.3,
        pH: 7.5,
        total_alkalinity: 100,
        calcium_hardness: 300
      }

      result = AdjustChemicals.adjust_all_parameters(input)

      assert is_float(result.free_chlorine)
      assert is_float(result.combined_chlorine)
      assert is_float(result.pH)
      assert is_float(result.total_alkalinity)
      assert is_float(result.calcium_hardness)
      assert abs(result.free_chlorine - 3.0) <= 0.2
      assert abs(result.pH - 7.5) <= 0.02
    end

    @doc """
    Verifies that values outside their desired ranges are adjusted towards the ideal range.
    """
    test "adjusts values up or down when outside of desired range_" do
      input = %{
        free_chlorine: 1.0,  # too low
        combined_chlorine: 0.6,  # too high
        pH: 7.0,  # too low
        total_alkalinity: 120,  # too high
        calcium_hardness: 100  # too low
      }

      result = AdjustChemicals.adjust_all_parameters(input)

      assert result.free_chlorine > 1.0
      assert result.combined_chlorine < 0.6
      assert result.pH > 7.0
      assert result.total_alkalinity < 120
      assert result.calcium_hardness > 100
    end

    @doc """
    Ensures that parameters not listed in the desired range are ignored.
    """
    test "ignores unknown parameters and keeps their values unchanged_" do
      input = %{
        free_chlorine: 2.5,
        unknown_param: 42
      }

      result = AdjustChemicals.adjust_all_parameters(input)

      assert Map.has_key?(result, :unknown_param)
      assert result.unknown_param == 42
    end

    @doc """
    Ensures "nil" values are skipped and left unchanged in the result.
    """
    test "skips parameters with nil values_" do
      input = %{
        free_chlorine: nil,
        pH: 7.5
      }

      result = AdjustChemicals.adjust_all_parameters(input)

      assert result.free_chlorine == nil
      assert is_float(result.pH)
    end
  end

  describe "adjust_parameter/2" do
    @doc """
    Adjusts a value to be higher if it is below the minimum range.
    """
    test "adjusts value upward if below range_" do
      result = AdjustChemicals.adjust_parameter(:pH, 7.0)

      assert is_float(result)
      assert result > 7.0
    end

    @doc """
    Adjusts a value to be lower if it is above the maximum range.
    """
    test "adjusts value downward if above range_" do
      result = AdjustChemicals.adjust_parameter(:combined_chlorine, 1.0)

      assert is_float(result)
      assert result < 1.0
    end

    @doc """
    Slightly adjusts a value randomly if it is already within desired range.
    """
    test "adjusts value randomly if within range_" do
      value = 7.5
      result = AdjustChemicals.adjust_parameter(:pH, value)

      assert is_float(result)
      assert abs(result - value) <= 0.1
    end

    @doc """
    Returns an error tuple if an unknown parameter is passed in to the adjust_parameter function
    """
    test "returns {:error, :unknown_parameter} for invalid param_" do
      result = AdjustChemicals.adjust_parameter(:invalid, 1.0)

      assert result == {:error, :unknown_parameter}
    end
  end
end
