import Config

config :multivac, Multivac.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 54322,
  pool_size: 10

config :multivac, ecto_repos: [Multivac.Repo]

config :multivac, Oban,
  repo: Multivac.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}],
  queues: [default: 10]

# Configure the role for the application
config :multivac, role: System.get_env("ROLE", "server")
