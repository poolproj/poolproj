# test_script.exs
# Test script for the PoolDowntime module

# Print a header
IO.puts("===== Testing Pool Downtime Management Module =====")

# Create test data
pool_id = "pool-123"
current_ph = 7.2
target_ph = 7.5

# Create datetime objects
start_time = DateTime.utc_now()
# Set end time to 2 hours later
end_time = DateTime.add(start_time, 7200, :second)

# Schedule a pH adjustment
IO.puts("\n1. Schedule pH Adjustment")
case PoolDowntime.schedule_ph_adjustment(pool_id, current_ph, target_ph, start_time, end_time) do
  {:ok, downtime} ->
    IO.puts("Successfully scheduled pH adjustment")
    IO.inspect(downtime, label: "Details")
  {:error, reason} ->
    IO.puts("Error: #{reason}")
end

# Estimate adjustment time
IO.puts("\n2. Estimate pH Adjustment Time")
pool_volume = 15000  # Assuming pool volume of 15,000 gallons
estimated_minutes = PoolDowntime.estimate_ph_adjustment_time(current_ph, target_ph, pool_volume)
IO.puts("Estimated time needed: #{estimated_minutes} minutes")

# Start pH adjustment
IO.puts("\n3. Start pH Adjustment")
downtime_id = "dt-123"  # Assumed ID
{:ok, started} = PoolDowntime.start_ph_adjustment(downtime_id)
IO.inspect(started, label: "Started adjustment")

# Complete pH adjustment
IO.puts("\n4. Complete pH Adjustment")
final_ph = 7.5  # Target pH reached
{:ok, completed} = PoolDowntime.complete_ph_adjustment(downtime_id, final_ph)
IO.inspect(completed, label: "Completed adjustment")

# Query maintenance history
IO.puts("\n5. Query Pool Maintenance History")
{:ok, history} = PoolDowntime.list_ph_adjustments(pool_id)
IO.inspect(history, label: "Maintenance history")

IO.puts("\n===== Test Complete =====")
