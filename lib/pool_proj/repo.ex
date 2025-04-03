defmodule PoolProj.Repo do
  use Ecto.Repo,
    otp_app: :pool_proj,
    adapter: Ecto.Adapters.Postgres
end

