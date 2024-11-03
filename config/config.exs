import Config

config :multivac_agent, MultivacAgent.Repo,
  database: "multivac_agent_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :multivac_agent, ecto_repos: [MultivacAgent.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"