defmodule CSVReader do
  @moduledoc """
  Provides functionality to load and parse a CSV file containing world cities.

  This module defines a single function, `load_csv/0`, which reads a CSV file
  containing city data and returns a list of maps with the city name, country,
  administrative region, and a unique city ID.

  The CSV file is located in the `priv/data` directory of the `:pool_proj` application.

  ## Author
  [author]

  ## Version
  [version]

  ## Complexity
  The module has a low complexity, handling basic file streaming and CSV parsing using `NimbleCSV`.

  ## Since
  2025-04-03
  """

  @csv_file Path.join(:code.priv_dir(:pool_proj), "data/worldcities.csv")

  NimbleCSV.define(MyCSVParser, separator: ",", escape: "\"")

  @doc """
  Loads and parses the world cities CSV file.

  The function reads the `worldcities.csv` file line by line, parses each row using
  a custom CSV parser (`MyCSVParser`), and extracts only relevant fields: the ASCII city name,
  the country name, the administrative region, and the city ID. It skips other fields such as
  latitude, longitude, and population.

  Returns a list of maps with the following keys:

    * `:city` – the ASCII name of the city
    * `:country` – the country name
    * `:state` – the name of the state or province
    * `:city_id` – the city's unique identifier as an integer

  ## Examples

      iex> CSVReader.load_csv()
      [
        %{city: "Tokyo", country: "Japan", state: "Tokyo", city_id: 123456},
        ...
      ]

  ## Author
  [author]

  ## Version
  1.0

  ## Complexity
  This function has low complexity, performing basic file streaming, CSV parsing, and mapping.

  ## Since
  2025-04-03
  """
  def load_csv do
    @csv_file
    |> File.stream!()
    |> MyCSVParser.parse_stream()
    |> Enum.map(fn [
                     city,
                     city_ascii,
                     _lat, _lng,
                     country,
                     _iso2, _iso3,
                     admin_name,
                     _capital,
                     _population,
                     id
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
