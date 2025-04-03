defmodule PoolMonitor do
  alias PoolProj.{Repo, PoolData}
  alias PoolSimulator
  alias PoolChemistryChecker

  def run do
    data = PoolSimulator.generate_data()

    IO.puts("Generated Pool Data:")
    IO.inspect(data)

    changeset = PoolData.changeset(%PoolData{}, data)

    case Repo.insert(changeset) do
      {:ok, record} ->
        IO.puts("\nSaved to DB")
        IO.inspect(record)

      {:error, reason} ->
        IO.puts("\nFailed to save pool data")
        IO.inspect(reason)
    end

    analysis = PoolChemistryChecker.check_levels(data)

    IO.puts("\nAnalysis & Recommendations:")
    IO.inspect(analysis)

    # I am putting a comment here to test something!
  end
end

# Run the program
# PoolMonitor.run()
