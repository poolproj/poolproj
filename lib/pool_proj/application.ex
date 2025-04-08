defmodule PoolProj.Application do
  use Application

  def start(_type, _args) do
    children = [
      PoolProj.Repo,
      SimulationServer
    ]

    opts = [strategy: :one_for_one, name: PoolProj.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
