import Config

config :multivac, Multivac.Repo,
  database: System.get_env("DATABASE_NAME"),
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASSWORD"),
  hostname: System.get_env("DATABASE_HOST"),
  port: System.get_env("DATABASE_PORT"),
  pool_size: 10

config :multivac, ecto_repos: [Multivac.Repo]

role = System.get_env("ROLE") || "server"

oban_config =
  case role do
    "worker" ->
      [
        repo: Multivac.Repo,
        queues: [default: 10],
        peer: Oban.Peers.Postgres,
        plugins: []
      ]

    "server" ->
      [
        repo: Multivac.Repo,
        plugins: [Oban.Plugins.Pruner],
        peer: Oban.Peers.Postgres,
        queues: []
      ]

    _ ->
      raise "Unknown role: #{role}"
  end

config :multivac, Oban, oban_config

# Configure the role for the application
config :multivac, role: System.get_env("ROLE", "server")
