defmodule CSVReader do
  @csv_file Path.join(:code.priv_dir(:pool_proj), "data/worldcities.csv")

  NimbleCSV.define(MyCSVParser, separator: ",", escape: "\"")

  def load_csv do
    @csv_file
    |> File.stream!()
    |> MyCSVParser.parse_stream()
    |> Enum.map(fn [
                   city,      # city
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
