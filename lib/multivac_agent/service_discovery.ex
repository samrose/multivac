defmodule MultivacAgent.ServiceDiscovery do
  alias MultivacAgent.Repo
  alias MultivacAgent.Service
  import Ecto.Query

  def register_service(service_name, hostname, ip_address, port, metadata \\ %{}) do
    %Service{}
    |> Service.changeset(%{
      service_name: service_name,
      hostname: hostname,
      ip_address: ip_address,
      port: port,
      metadata: metadata
    })
    |> Repo.insert_or_update()
  end

  def get_service(service_name) do
    Service
    |> where([s], s.service_name == ^service_name)
    |> Repo.one()
  end

  def list_services do
    Repo.all(Service)
  end

  def update_service(id, attrs) do
    Service
    |> Repo.get(id)
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  def delete_service(id) do
    Service
    |> Repo.get(id)
    |> Repo.delete()
  end
end