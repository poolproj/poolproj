import Config
config :pool_proj, PoolProj.Repo,
  username: "aaron",
  password: "password",
  database: "defaultdb",
  hostname: "24.199.108.23",
  port: 26257,
  pool_size: 10,
  ssl: false,
  migration_lock: nil 

config :pool_proj,
  ecto_repos: [PoolProj.Repo]

