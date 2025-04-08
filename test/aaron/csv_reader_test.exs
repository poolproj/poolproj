defmodule CSVReaderTest do
  use ExUnit.Case

  alias CSVReader

  test "load_csv/0 returns a non-empty list" do
    result = CSVReader.load_csv()

    assert is_list(result)
    assert length(result) > 0
  end

  test "each entry is a map with expected keys" do
    [first | _] = CSVReader.load_csv()

    assert is_map(first)
    assert Map.has_key?(first, :city)
    assert Map.has_key?(first, :country)
    assert Map.has_key?(first, :state)
    assert Map.has_key?(first, :city_id)
  end

  test "city_id is an integer" do
    [first | _] = CSVReader.load_csv()
    assert is_integer(first.city_id)
  end

  test "load_csv returns different entries (not all the same)" do
    cities = CSVReader.load_csv()
    cities_unique = Enum.uniq_by(cities, fn city -> city.city_id end)

    assert length(cities_unique) > 1
  end

  test "all cities have non-empty city names" do
    CSVReader.load_csv()
    |> Enum.each(fn city ->
      assert is_binary(city.city)
      assert String.length(String.trim(city.city)) > 0
    end)
  end
end
