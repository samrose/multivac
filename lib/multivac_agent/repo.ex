defmodule MultivacAgent.Repo do
  use Ecto.Repo,
    otp_app: :multivac_agent,
    adapter: Ecto.Adapters.Postgres
end