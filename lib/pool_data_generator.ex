defmodule PoolSimulator do

  # UPDATED - Now this generates just initial data, and nothing to do with the pool itself
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
