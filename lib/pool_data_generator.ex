defmodule PoolSimulator do
  def generate_data do
    location = get_random_location()

    %{
      free_chlorine: Float.round(:rand.uniform() * 7, 2),
      combined_chlorine: Float.round(:rand.uniform() * 1, 2),
      pH: Float.round(:rand.uniform() * 4 + 6, 2),
      total_alkalinity: Enum.random(40..200),
      calcium_hardness: Enum.random(50..1200),
      pool_volume: Enum.random(10_000..30_000),
      location: location
    }
  end

  defp get_random_location do
    addresses = CSVReader.load_csv()
    Enum.random(addresses)
  end
end

