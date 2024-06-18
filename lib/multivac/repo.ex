defmodule Multivac.Repo do
  use Ecto.Repo,
    otp_app: :multivac,
    adapter: Ecto.Adapters.Postgres
end
