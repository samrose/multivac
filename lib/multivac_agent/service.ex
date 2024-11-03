defmodule MultivacAgent.Service do
  use Ecto.Schema
  import Ecto.Changeset

  schema "service_discovery" do
    field :service_name, :string
    field :hostname, :string
    field :ip_address, :string
    field :port, :integer
    field :metadata, :map

    timestamps()
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:service_name, :hostname, :ip_address, :port, :metadata])
    |> validate_required([:service_name, :hostname, :ip_address, :port])
  end
end