import Config
config :pool_proj, PoolProj.Repo,
  username: "aaron",
  password: "password",
  database: "pool_proj",
  hostname: "24.199.108.23",
  port: 26257,
  pool_size: 10,
  ssl: false,
  migration_lock: nil

config :pool_proj,
  ecto_repos: [PoolProj.Repo]

# cockroach sql --insecure --host=localhost:26257 --database=pool_proj
