import Config

config :multivac, Multivac.MultivacLibcluster, enabled: false
config :multivac, Multivac.BaseAgent, enabled: true
config :logger, :console,
  format: "[$level][node:$node] $message\n", metadata: [:node]

config :libcluster, topologies: [
  postgres: [
    strategy: LibclusterPostgres.Strategy,
    config: [
      hostname: "localhost",
      username: "postgres",
      password: "postgres",
      database: "postgres",
      port: 54322,
      parameters: [],
      channel_name: "cluster"
    ]
  ]
]



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
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

config :multivac, Oban,
  repo: Multivac.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]
