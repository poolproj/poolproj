defmodule PoolMonitor do
  @moduledoc """
  Provides an entry point to simulate pool chemical data, analyze the levels,
  and display recommendations along with adjusted chemical actions.

  This module serves as the coordinator between data generation, analysis via
  `PoolChemistryChecker`, and adjustment using `AdjustChemicals`.

  ## Responsibilities

    - Generates synthetic pool data.
    - Displays chemical analysis and recommendations.
    - Applies adjustments based on analysis and displays results.

  Intended to be run manually or invoked from a scheduler or testing routine.

  > Note: This module assumes the existence of `PoolSimulator`, `PoolChemistryChecker`,
  > and `AdjustChemicals` modules.

  @author 1.0
  @version [version]
  @complexity Low
  @since 2025-04-03
  """

  @doc """
  Runs the full pool monitoring workflow:
    1. Generates simulated pool data.
    2. Checks chemical levels and outputs analysis.
    3. Applies necessary chemical adjustments and displays results.

  ## Output

    - Printed pool data
    - Printed chemical level analysis
    - Printed chemical adjustment recommendations

  @complexity Low
  @since 2025-04-03
  @version 1.0
  @author [author]
  """
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
