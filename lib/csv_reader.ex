defmodule CSVReader do
  @moduledoc """
  Handles reading and parsing of a CSV file containing world city data.

  This module parses a static CSV file (`priv/data/worldcities.csv`) and transforms
  each row into a map containing selected city metadata.

  The CSV is expected to follow the `worldcities.csv` structure, and is parsed using
  `NimbleCSV` for efficiency and correctness.

  ## CSV Fields Used

    * `city_ascii` - ASCII-safe name of the city
    * `country` - Name of the country
    * `admin_name` - State or province
    * `id` - Unique city identifier

  ## Example

      CSVReader.load_csv()
      #=> [%{city: "Phoenix", country: "United States", state: "Arizona", city_id: 12345}, ...]

  > The file is expected at: `priv/data/worldcities.csv`

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low
  @since 2025-04-07
  """
  @csv_file Path.join(:code.priv_dir(:pool_proj), "data/worldcities.csv")

  NimbleCSV.define(MyCSVParser, separator: ",", escape: "\"")

  @doc """
  Parses the `worldcities.csv` file and returns a list of maps with selected city data.

  Each map includes:
    * `:city` - ASCII-safe city name
    * `:country` - Country name
    * `:state` - Admin name (state/province)
    * `:city_id` - Integer ID from the CSV

  ## Returns

    * A list of maps representing cities

  ## Example

      CSVReader.load_csv()
      [
        %{city: "Berlin", country: "Germany", state: "Berlin", city_id: 3001},
        %{city: "Madrid", country: "Spain", state: "Madrid", city_id: 4023},
        ...
      ]

  > Ignores unused CSV fields for performance and clarity.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Stream parses file and maps selected values.
  @since 2025-04-07
  """
  def load_csv do
    @csv_file
    |> File.stream!()
    |> MyCSVParser.parse_stream()
    |> Enum.map(fn [
                   _city,      # city
                   city_ascii, # city_ascii
                   _lat, _lng, # skipping lat, lng
                   country,   # country
                   _iso2, _iso3, # skipping iso codes
                   admin_name, # admin_name (state/province)
                   _capital, # skipping capital
                   _population, # skipping population
                   id         # id
                 ] ->
      %{
        city: city_ascii,
        country: country,
        state: admin_name,
        city_id: String.to_integer(id)
      }
    end)
  end
end
