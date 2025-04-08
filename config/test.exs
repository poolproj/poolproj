import Config

config :pool_proj, PoolProj.Repo,
  username: "aaron",
  password: "password",
  database: "pool_proj_test",
  hostname: "localhost",
  port: 26257,
  pool: Ecto.Adapters.SQL.Sandbox,
  ssl: false,
  migration_lock: nil

config :pool_proj,
  ecto_repos: [PoolProj.Repo]
