defmodule PoolChemistryChecker do
  @desired_ranges %{
    free_chlorine: {2.0, 4.0},
    combined_chlorine: {0.0, 0.5},
    pH: {7.4, 7.6},
    total_alkalinity: {90, 110},
    calcium_hardness: {200, 400}
  }

  @chemical_dosages %{
    chlorine: 0.00013, # oz per gallon to increase 1 ppm
    sodium_thiosulfate: 0.00015, # oz per gallon to decrease chlorine
    soda_ash: 0.0015, # oz per gallon to raise pH
    muriatic_acid: 0.002, # oz per gallon to lower pH
    baking_soda: 0.002, # oz per gallon to raise alkalinity
    calcium_chloride: 0.0015, # oz per gallon to increase hardness
    clarifier: 0.0002 # oz per gallon to increase clarity of cloudy water
  }

  def check_levels(pool_data) do
    %{
      free_chlorine: balance_free_chlorine(pool_data.pool_volume, pool_data.free_chlorine),
      combined_chlorine: balance_combined_chlorine(pool_data.pool_volume, pool_data.combined_chlorine),
      pH: balance_pH(pool_data.pool_volume, pool_data.pH),
      total_alkalinity: balance_total_alkalinity(pool_data.pool_volume, pool_data.total_alkalinity),
      calcium_hardness: balance_calcium_hardness(pool_data.pool_volume, pool_data.calcium_hardness)
    }
  end

  defp balance_free_chlorine(volume, value) do
    {min, max} = @desired_ranges.free_chlorine

    cond do
      value < min ->
        amount = Float.round((min - value) * volume * @chemical_dosages.chlorine, 2)
        {:low, "Add #{amount} oz of chlorine to increase free chlorine."}

      value > max ->
        amount = Float.round((value - max) * volume * @chemical_dosages.sodium_thiosulfate, 2)
        {:high, "Add #{amount} oz of sodium thiosulfate to reduce free chlorine."}

      true ->
        {:ok, "Free chlorine is within range."}
    end
  end

  defp balance_combined_chlorine(volume, value) do
    {_, max} = @desired_ranges.combined_chlorine

    if value > max do
      # Breakpoint chlorination requires Free Chlorine to be increased by Combined Chlorine * 10
      required_chlorine_increase = value * 10
      amount = Float.round(required_chlorine_increase * volume * @chemical_dosages.chlorine, 2)

      {:high, "Shock the pool by adding #{amount} oz of chlorine to remove combined chlorine."}
    else
      {:ok, "Combined chlorine is within range."}
    end
  end

  defp balance_pH(volume, value) do
    {min, max} = @desired_ranges.pH

    cond do
      value < min ->
        amount = Float.round((min - value) * volume * @chemical_dosages.soda_ash, 2)
        {:low, "Add #{amount} oz of soda ash to increase pH."}

      value > max ->
        amount = Float.round((value - max) * volume * @chemical_dosages.muriatic_acid, 2)
        {:high, "Add #{amount} oz of muriatic acid to lower pH."}

      true ->
        {:ok, "pH is within range."}
    end
  end

  defp balance_total_alkalinity(volume, value) do
    {min, max} = @desired_ranges.total_alkalinity

    cond do
      value < min ->
        amount = Float.round((min - value) * volume * @chemical_dosages.baking_soda, 2)
        {:low, "Add #{amount} oz of baking soda to increase alkalinity."}

      value > max ->
        amount = Float.round((value - max) * volume * @chemical_dosages.muriatic_acid, 2)
        {:high, "Add #{amount} oz of muriatic acid to lower alkalinity."}

      true ->
        {:ok, "Total alkalinity is within range."}
    end
  end

  defp balance_calcium_hardness(volume, value) do
    {min, max} = @desired_ranges.calcium_hardness

    cond do
      value < min ->
        amount = Float.round((min - value) * volume * @chemical_dosages.calcium_chloride, 2)
        {:low, "Add #{amount} oz of calcium chloride to increase hardness."}

      value > max ->
        {:high, "Dilute pool water with fresh water to lower calcium hardness."}

      true ->
        {:ok, "Calcium hardness is within range."}
    end
  end
end
