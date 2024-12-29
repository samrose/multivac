import Config

config :multivac_agent, MultivacAgent.Repo,
  database: System.get_env("PGDATABASE", "postgres"),
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD"),
  hostname: System.get_env("PGHOST"),
  port: String.to_integer(System.get_env("PGPORT", "5432"))

config :multivac_agent, ecto_repos: [MultivacAgent.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
