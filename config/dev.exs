import Config

config :multivac_agent, MultivacAgent.Repo,
  database: System.get_env("PGDATABASE", "postgres"),
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD"),
  hostname: System.get_env("PGHOST"),
  port: String.to_integer(System.get_env("PGPORT", "5432")),
  ssl: true,
  socket_options: [:inet6],  # Add this line to enable IPv6
  ssl_opts: [
    verify: :verify_none
  ],
  pool_size: 10

config :multivac_agent, ecto_repos: [MultivacAgent.Repo]

# Additional development-specific configurations can go here