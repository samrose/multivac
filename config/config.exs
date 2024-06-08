import Config

config :multivac, Multivac.MultivacLibcluster, enabled: true
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
