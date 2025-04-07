defmodule PoolGenerator do
  # UPDATED - This generates just the pool (location, volume)
  # It does not do anything with the pool_data.
  def generate_pool do
    %{
      location: random_location(),
      volume: Enum.random(10_000..30_000)
    }
  end

  defp random_location do
    CSVReader.load_csv()
    |> Enum.random()
    |> Jason.encode!()
  end
end
