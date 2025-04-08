defmodule SimulationServer do
  use GenServer

  alias PoolProj.{Repo, Pool}
  alias PoolMonitor

  ## Client API

  def start_link(_opts) do
    IO.puts("✅ SimulationServer starting...")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

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
