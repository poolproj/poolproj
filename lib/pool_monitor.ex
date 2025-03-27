defmodule PoolMonitor do
  def run do
    pool_data = PoolSimulator.generate_data()
    IO.puts("Generated Pool Data:")
    IO.inspect(pool_data)

    analysis = PoolChemistryChecker.check_levels(pool_data)
    IO.puts("\nAnalysis & Recommendations:")
    IO.inspect(analysis)

    adjusted = AdjustChemicals.adjust_all_parameters(pool_data)
    IO.puts("\nAdjusted Chemicals:")
    IO.inspect(adjusted)

  end
end

# Run the program
# PoolMonitor.run()
