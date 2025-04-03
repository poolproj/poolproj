defmodule PoolChemistryChecker do
  @moduledoc """
  Provides functionality to analyze and adjust pool chemical levels to maintain proper water balance.

  This module checks five critical chemical parameters in pool water, free chlorine, combined chlorine,
  pH, total alkalinity, and calcium hardness, against recommended ranges. Based on deviations from
  the desired range, it calculates the necessary chemical dosages for correction.

  ## Features

    - Verifies if current pool chemical levels fall within desired thresholds.
    - Suggests dosage amounts and specific chemicals for adjustments.
    - Supports shock treatment for combined chlorine issues.
    - Returns descriptive messages for pool maintenance actions.

  @author [author]
  @version 1.0
  @complexity Medium
  @since 2025-04-03
  """

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

  @doc """
  Analyzes the current chemical levels of a pool and provides recommendations for adjustments.

  ## Parameters

    - `pool_data` (map): A map containing:
      - `:pool_volume` (float): Pool volume in gallons.
      - `:free_chlorine` (float): Current free chlorine level (ppm).
      - `:combined_chlorine` (float): Current combined chlorine level (ppm).
      - `:pH` (float): Current pH level.
      - `:total_alkalinity` (integer): Current alkalinity (ppm).
      - `:calcium_hardness` (integer): Current calcium hardness (ppm).

  ## Returns

    - A map containing the status of each chemical parameter as `:ok`, `:low`, or `:high` with
      recommended actions.

  @complexity Low
  @since 2025-04-03
  @author [author]
  @version 1.0
  """
  def check_levels(pool_data) do
    %{
      free_chlorine: balance_free_chlorine(pool_data.pool_volume, pool_data.free_chlorine),
      combined_chlorine: balance_combined_chlorine(pool_data.pool_volume, pool_data.combined_chlorine),
      pH: balance_pH(pool_data.pool_volume, pool_data.pH),
      total_alkalinity: balance_total_alkalinity(pool_data.pool_volume, pool_data.total_alkalinity),
      calcium_hardness: balance_calcium_hardness(pool_data.pool_volume, pool_data.calcium_hardness)
    }
  end

  @doc """
  Determines whether free chlorine is within the acceptable range and suggests dosage if not.

  @complexity Low
  @since 2025-04-03
  @author [author]
  @version 1.0
  """
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

  @doc """
  Checks combined chlorine levels and recommends a shock treatment if necessary.

  @complexity Low
  @since 2025-04-03
  @author [author]
  @version 1.0
  """
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

  @doc """
  Evaluates the pH level and recommends an acid or base treatment to adjust it.

  @complexity Low
  @since 2025-04-03
  @version 1.0
  @author [author]
  """
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

  @doc """
  Analyzes total alkalinity and suggests increasing or decreasing it using appropriate chemicals.

  @complexity Low
  @since 2025-04-03
  @version 1.0
  @author [author]
  """
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

  @doc """
  Assesses calcium hardness and recommends increasing with calcium chloride or dilution if too high.

  @complexity Low
  @since 2025-04-03
  @version 1.0
  @author [author]
  """
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
