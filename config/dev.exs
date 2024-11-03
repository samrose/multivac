import Config

config :multivac_agent, MultivacAgent.Repo,
  database: "multivac_agent_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5435,
  pool_size: 10

config :multivac_agent, ecto_repos: [MultivacAgent.Repo]

# Additional development-specific configurations can go here