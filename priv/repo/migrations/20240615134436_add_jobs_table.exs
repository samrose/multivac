defmodule Multivac.Repo.Migrations.AddJobsTable do
  use Ecto.Migration

  def up do
    # Create the Oban jobs table in the public schema
    create table(:jobs, primary_key: false, prefix: "public") do
      add :id, :bigserial, primary_key: true
      add :state, :string, null: false
      add :queue, :string, null: false
      add :worker, :string, null: false
      add :args, :map, null: false
      add :errors, :map, default: %{}, null: false
      add :attempt, :integer, default: 0, null: false
      add :max_attempts, :integer, default: 1, null: false
      add :scheduled_at, :utc_datetime_usec, null: false
      add :attempted_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
      add :discarded_at, :utc_datetime_usec
      add :priority, :integer, default: 0, null: false
      add :tags, {:array, :string}, default: []

      timestamps(type: :utc_datetime_usec)
    end

    create index(:jobs, [:state], prefix: "public")
    create index(:jobs, [:queue], prefix: "public")
    create index(:jobs, [:worker], prefix: "public")
    create index(:jobs, [:scheduled_at], prefix: "public")

    # Create the function for notifying on insert in the public schema
    execute """
    CREATE OR REPLACE FUNCTION public.notify_jobs_table_insert() RETURNS TRIGGER AS $$
    BEGIN
      PERFORM pg_notify('jobs_table_insert_channel', row_to_json(NEW)::text);
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    # Create the trigger for the jobs table in the public schema
    execute """
    CREATE TRIGGER jobs_table_insert_trigger
    AFTER INSERT ON public.jobs
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_jobs_table_insert();
    """
  end

  def down do
    # Drop the trigger in the public schema
    execute "DROP TRIGGER IF EXISTS jobs_table_insert_trigger ON public.jobs;"

    # Drop the function in the public schema
    execute "DROP FUNCTION IF EXISTS public.notify_jobs_table_insert();"

    # Drop the jobs table in the public schema
    execute "DROP TABLE IF EXISTS public.jobs;"

    # Drop the Oban jobs table in the public schema
    drop table(:jobs, prefix: "public")
  end
end
