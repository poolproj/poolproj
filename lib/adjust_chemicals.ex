defmodule PoolDataAdjuster do
  @moduledoc """
  Provides functionality to automatically adjust various chemical parameters
  in pool water to fall within recommended safe and effective ranges.

  This module includes logic for adjusting values either up, down, or randomly within
  an acceptable range, based on desired thresholds for water chemistry.

  ## Author
  Grant Watson

  ## Version
  1.0

  ## Complexity
  Medium

  ## Since
  2025-04-03
  """

  @desired_ranges %{
    free_chlorine: {2.0, 4.0},
    combined_chlorine: {0.0, 0.5},
    pH: {7.4, 7.6},
    total_alkalinity: {90, 110},
    calcium_hardness: {200, 400}
  }

    @doc """
    Iterates through all known chemical parameters and adjusts each present one
    in the provided pool data to bring it closer to its ideal range.

    ## Parameters
      - pool_data: A map of pool chemical values (e.g., `%{pH: 6.8, free_chlorine: 1.5}`).

    ## Returns
      - A map with adjusted chemical values, retaining unchanged parameters if not in known list.

    ## Complexity
    Medium

    ## Since
    2025-04-03
    """
  def adjust(%{} = measurement) do
    original = Map.from_struct(measurement)

    adjusted_chemicals =
      original
      |> Map.take(Map.keys(@desired_ranges))
      |> adjust_all_parameters()

    Map.merge(original, adjusted_chemicals)
  end


  defp adjust_all_parameters(data) do
    Enum.reduce(@desired_ranges, data, fn {key, _}, acc ->
      case Map.get(acc, key) do
        nil -> acc
        value -> Map.put(acc, key, adjust_parameter(key, value))
      end
    end)
  end

   @doc """
  Adjusts a single chemical parameter value to bring it within its desired range.

  ## Parameters
    - param: The name of the chemical parameter (e.g., `:pH`).
    - value: The current numeric value of the parameter.

  ## Returns
    - A new value adjusted toward the acceptable range.
    - `{:error, :unknown_parameter}` if the parameter is not recognized.

  ## Complexity
  Medium

  ## Since
  2025-04-03
  """

  def adjust_parameter(param, value) do
    case Map.get(@desired_ranges, param) do
      {min, max} when is_number(value) ->
        cond do
          value < min -> adjust_up(value, min, max)
          value > max -> adjust_down(value, min, max)
          true -> adjust_randomly(value, min, max)
        end

      _ -> value
    end
  end

  defp adjust_up(value, min, max) do
    range = (max - min) * 0.25
    Float.round(value + :rand.uniform() * range, 2)
  end

  defp adjust_down(value, min, max) do
    range = (max - min) * 0.25
    Float.round(value - :rand.uniform() * range, 2)
  end

  defp adjust_randomly(value, min, max) do
    range = (max - min) * 0.1
    Float.round(value + (:rand.uniform() * 2 - 1) * range, 2)
  end
end
