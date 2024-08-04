defmodule Multivac.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # Define children to be supervised
    children = [
      # Start the Ecto repository
      Multivac.Repo,
      # Start Oban with runtime configuration
      {Oban, Application.fetch_env!(:multivac, Oban)}
    ]

    # Add role-specific children
    role = System.get_env("ROLE") || "server"

    children =
      case role do
        "server" ->
          children ++ [Multivac.Listener, Multivac.JobStatusListener]

        "worker" ->
          children

        _ ->
          raise "Unknown role: #{role}"
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: Multivac.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
