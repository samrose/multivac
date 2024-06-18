defmodule Multivac.Repo.Migrations.AddObanJobsAndPeers do
  use Ecto.Migration

  def up do
    Oban.Migrations.up(version: 11, prefix: "public")
  end

  def down do
    Oban.Migrations.down(version: 0, prefix: "public")
  end
end
