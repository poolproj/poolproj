defmodule PoolGenerator do
  @moduledoc """
  Generates simulated pool data for use in testing, seeding, or simulation systems.

  This module uses a random city from a parsed CSV file and assigns a random volume to the pool,
  making it useful for populating databases with realistic test data.

  ## Example

      PoolGenerator.generate_pool()
      #=> %{location: "{\"city\":\"Paris\",\"country\":\"France\",...}", volume: 12345}

  > The location is JSON-encoded for consistency with external systems or storage formats.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low
  @since 2025-04-07
  """

  @doc """
  Generates a single pool data map with a random location and volume.

  The location is randomly selected from a list of cities loaded from a CSV file,
  and encoded as a JSON string.

  The volume is a randomly generated integer between 10,000 and 30,000.

  ## Returns

    * A map with the following keys:
      * `:location` - A JSON string containing a randomly selected city
      * `:volume` - An integer representing pool volume in liters

  ## Example

      PoolGenerator.generate_pool()
      #=> %{location: "{\"city\":\"Austin\",\"country\":\"USA\",...}", volume: 25234}

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Combines random selection and JSON encoding.
  @since 2025-04-07
  """
  def generate_pool do
    %{
      location: random_location(),
      volume: Enum.random(10_000..30_000)
    }
  end

  @doc"""
  Selects a random city from the CSVReader's list of cities and encodes it as a JSON string.

  Used internally by `generate_pool/0` to assign a randomized location.

  ## Returns

    * A JSON string representing a randomly selected city record

  > This function is private and should not be used externally.

  @example

      "{\"city\":\"Tokyo\",\"country\":\"Japan\",\"state\":\"Tokyo\",\"city_id\":1122}"

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Random selection and JSON encoding of preloaded list.
  @since 2025-04-07
  """
  def random_location do
    CSVReader.load_csv()
    |> Enum.random()
    |> Jason.encode!()
  end
end
