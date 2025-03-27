defmodule AdjustChemicals do
  @desired_ranges %{
    free_chlorine: {2.0, 4.0},
    combined_chlorine: {0.0, 0.5},
    pH: {7.4, 7.6},
    total_alkalinity: {90, 110},
    calcium_hardness: {200, 400}
  }

  def adjust_all_parameters(pool_data) do
    Enum.reduce(@desired_ranges, pool_data, fn {key, _range}, acc ->
      case Map.get(pool_data, key) do
        nil -> acc
        value -> Map.put(acc, key, adjust_parameter(key, value))
      end
    end)
  end

  def adjust_parameter(param, value) do
    case Map.get(@desired_ranges, param) do
      {min, max} when is_number(value) ->
        cond do
          value < min ->
            adjust_up(value, min, max)

          value > max ->
            adjust_down(value, min, max)

          true ->
            adjust_randomly(value, min, max)
        end

      _ ->
        {:error, :unknown_parameter}
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
