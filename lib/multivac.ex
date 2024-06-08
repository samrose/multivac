defmodule Multivac.MultivacLibcluster do
  use Application

  def start(_type, _args) do
    if enabled?() do
      topologies = Application.get_env(:libcluster, :topologies, [])
      children = [
        {Cluster.Supervisor, [topologies, [name: Multivac.ClusterSupervisor]]},
        NodeCheck
      ]
      opts = [strategy: :one_for_one, name: Multivac.LibclusterSupervisor]
      Supervisor.start_link(children, opts)
    else
      # Start a dummy supervisor to avoid crashing
      children = []
      opts = [strategy: :one_for_one, name: Multivac.DummySupervisor]
      Supervisor.start_link(children, opts)
    end
  end

  defp enabled? do
    Application.get_env(:multivac, __MODULE__, [])[:enabled] == true
  end
end
