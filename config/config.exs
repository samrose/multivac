import Config

config :multivac, Multivac.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 54322,
  pool_size: 10

config :multivac, ecto_repos: [Multivac.Repo]

role = System.get_env("ROLE") || "server"

oban_config =
  case role do
    "worker" ->
      [
        repo: Multivac.Repo,
        queues: [default: 10],
        plugins: []
      ]

    "server" ->
      [
        repo: Multivac.Repo,
        plugins: [Oban.Plugins.Pruner],
        queues: []
      ]

    _ ->
      raise "Unknown role: #{role}"
  end

config :multivac, Oban, oban_config

# Configure the role for the application
config :multivac, role: System.get_env("ROLE", "server")
