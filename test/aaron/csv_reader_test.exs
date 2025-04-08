defmodule CSVReaderTest do
  use ExUnit.Case
  alias CSVReader

  # Load the CSV file once and pass the result to all tests
  setup_all do
    cities = CSVReader.load_csv()
    {:ok, cities: cities}
  end

  test "load_csv/0 returns a non-empty list", %{cities: cities} do
    assert is_list(cities)
    assert length(cities) > 0
  end

  test "each entry is a map with expected keys", %{cities: cities} do
    [first | _] = cities

    assert is_map(first)
    assert Map.has_key?(first, :city)
    assert Map.has_key?(first, :country)
    assert Map.has_key?(first, :state)
    assert Map.has_key?(first, :city_id)
  end

  test "city_id is an integer", %{cities: cities} do
    [first | _] = cities
    assert is_integer(first.city_id)
  end

  test "load_csv returns different entries (not all the same)", %{cities: cities} do
    cities_unique = Enum.uniq_by(cities, fn city -> city.city_id end)
    assert length(cities_unique) > 1
  end

  test "all cities have non-empty city names", %{cities: cities} do
    Enum.each(cities, fn city ->
      trimmed = String.trim(city.city)
      assert is_binary(city.city)
      assert String.length(trimmed) > 0
    end)
  end
end
