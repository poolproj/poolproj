defmodule SimulationServer do
  @moduledoc """
  `SimulationServer` is a `GenServer` responsible for coordinating daily simulations
  of pool data using the `PoolMonitor` module.

  This server retrieves all pool records from the database and processes them
  concurrently using asynchronous tasks.

  ## Usage

  To start the simulation server:

      SimulationServer.start_link([])

  To simulate a day (e.g., from a scheduled task or external trigger):

      SimulationServer.simulate_day()

  ## Author
  Grant

  ## Version
  1.0.0

  ## Complexity
  This module includes asynchronous task execution and GenServer state management,
  making it of moderate complexity.

  ## Since
  2025-04-08
  """

  use GenServer

  alias PoolProj.{Repo, Pool}
  alias PoolMonitor

  ## Client API

  @doc """
  Starts the `SimulationServer` as a GenServer.

  ## Author
  Grant

  ## Version
  1.0.0

  ## Complexity
  Simple function to start a GenServer.

  ## Since
  2025-04-08
  """
  def start_link(_opts) do
    IO.puts("✅ SimulationServer starting...")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Triggers the simulation of a single day by sending an asynchronous
  message to the GenServer.

  This will initiate the processing of all pools using `PoolMonitor.process_pool/1`.

  ## Author
  Grant

  ## Version
  1.0.0

  ## Complexity
  Simple GenServer interface to delegate simulation work.

  ## Since
  2025-04-08
  """
  def simulate_day do
    GenServer.cast(__MODULE__, :simulate)
  end

  @impl true
  def init(state) do
    IO.puts("🟢 SimulationServer initialized")
    {:ok, state}
  end

  @impl true
  def handle_cast(:simulate, state) do
    IO.puts("🚀 [GenServer] Starting daily simulation...")

    Repo.all(Pool)
    |> Task.async_stream(&PoolMonitor.process_pool/1, max_concurrency: 10, timeout: :infinity)
    |> Stream.run()

    {:noreply, state}
  end
end
