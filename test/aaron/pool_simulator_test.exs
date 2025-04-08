defmodule PoolSimulatorTest do
  use ExUnit.Case

  test "generate_initial_data returns expected keys" do
    result = PoolSimulator.generate_initial_data()

    expected_keys = [
      :free_chlorine,
      :combined_chlorine,
      :pH,
      :total_alkalinity,
      :calcium_hardness
    ]

    assert is_map(result)
    assert Enum.all?(expected_keys, &Map.has_key?(result, &1))
  end

  test "chemical values are within expected ranges" do
    result = PoolSimulator.generate_initial_data()

    assert result.free_chlorine >= 0.0 and result.free_chlorine <= 7.0
    assert result.combined_chlorine >= 0.0 and result.combined_chlorine <= 1.0
    assert result.pH >= 6.0 and result.pH <= 10.0
    assert result.total_alkalinity >= 40 and result.total_alkalinity <= 200
    assert result.calcium_hardness >= 50 and result.calcium_hardness <= 1200
  end

  test "free_chlorine and pH are rounded to 2 decimal places" do
    result = PoolSimulator.generate_initial_data()

    assert Float.round(result.free_chlorine, 2) == result.free_chlorine
    assert Float.round(result.pH, 2) == result.pH
    assert Float.round(result.combined_chlorine, 2) == result.combined_chlorine
  end

  test "generate_initial_data is randomized" do
    r1 = PoolSimulator.generate_initial_data()
    r2 = PoolSimulator.generate_initial_data()

    refute r1 == r2
  end
end
