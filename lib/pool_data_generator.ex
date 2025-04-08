defmodule PoolSimulator do

  @moduledoc """
  Simulates initial water chemistry data for a pool without any dependency on specific pool attributes.

  This module generates randomized chemical readings that can be used when initializing a pool
  or running simulations. The values are within typical real-world ranges for pool water chemistry.

  ## Chemical Fields Simulated

    * `free_chlorine` - ppm (0.0 - 7.0)
    * `combined_chlorine` - ppm (0.0 - 1.0)
    * `pH` - range from 6.0 to 10.0
    * `total_alkalinity` - ppm (40 to 200)
    * `calcium_hardness` - ppm (50 to 1200)

  ## Example

      PoolSimulator.generate_initial_data()
      #=> %{free_chlorine: 2.87, combined_chlorine: 0.54, pH: 7.8, ...}

  > This data can be used to populate measurement records for a newly created pool in simulations or testing environments.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low
  @since 2025-04-07
  """

  @doc """
  Generates a randomized set of initial chemical readings for a pool.

  ## Returns

    * A map with the following keys:
      * `:free_chlorine` - Random float between 0.0 and 7.0 (rounded to 2 decimals)
      * `:combined_chlorine` - Random float between 0.0 and 1.0
      * `:pH` - Random float between 6.0 and 10.0
      * `:total_alkalinity` - Random integer between 40 and 200
      * `:calcium_hardness` - Random integer between 50 and 1200

  ## Example

      PoolSimulator.generate_initial_data()
      #=> %{
        free_chlorine: 3.42,
        combined_chlorine: 0.37,
        pH: 8.21,
        total_alkalinity: 95,
        calcium_hardness: 300
      }

  > These values represent realistic chemical starting points for pool water analysis and simulation routines.

  @author Aaron Alexander
  @version 1.0.0
  @complexity Low - Uses standard random number generation to populate fields.
  @since 2025-04-07
  """

  def generate_initial_data do
    %{
      free_chlorine: Float.round(:rand.uniform() * 7, 2),
      combined_chlorine: Float.round(:rand.uniform() * 1, 2),
      pH: Float.round(:rand.uniform() * 4 + 6, 2),
      total_alkalinity: Enum.random(40..200),
      calcium_hardness: Enum.random(50..1200)
    }
  end
end
