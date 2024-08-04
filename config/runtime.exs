import Config

# Load DATABASE_URL from environment variable in runtime
# database_url = System.get_env("DATABASE_URL")

# if database_url do
#   config :multivac, Multivac.Repo,
#     url: database_url,
#     pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
# end

config :multivac, Multivac.Repo,
  database: System.get_env("DATABASE_NAME"),
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASSWORD"),
  hostname: System.get_env("DATABASE_HOST"),
  port: System.get_env("DATABASE_PORT"),
  pool_size: 10


# Determine role from the environment variable
role = System.get_env("ROLE") || "server"

oban_config =
  case role do
    "worker" ->
      [
        queues: [default: 10],
        plugins: []
      ]

    "server" ->
      [
        plugins: [Oban.Plugins.Pruner],
        queues: []
      ]

    _ ->
      raise "Unknown role: #{role}"
  end

config :multivac, Oban, oban_config

# Logger configuration for all environments
config :logger, level: :info

if config_env() == :dev do
  config :logger, level: :debug
end

if config_env() == :test do
  config :multivac, Multivac.Repo,
    username: "postgres",
    password: "postgres",
    database: "multivac_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

  config :multivac, Oban,
    repo: Multivac.Repo,
    plugins: false,
    queues: false

  config :logger, level: :warn
end
