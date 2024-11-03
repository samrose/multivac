# File: lib/multivac_agent/job.ex

defmodule MultivacAgent.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias MultivacAgent.Repo

  schema "jobs" do
    field :command, :string
    field :status, :string, default: "pending"
    field :result, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:command, :status, :result])
    |> validate_required([:command])
    |> validate_inclusion(:status, ["pending", "running", "completed", "failed"])
    |> validate_length(:status, max: 20)
  end

  def create_job(attrs \\ %{}) do
    %MultivacAgent.Job{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_job!(id), do: Repo.get!(MultivacAgent.Job, id)

  def list_jobs do
    Repo.all(MultivacAgent.Job)
  end

  def list_pending_jobs(limit \\ 10) do
    MultivacAgent.Job
    |> where([j], j.status == "pending")
    |> limit(^limit)
    |> Repo.all()
  end

  def update_job(%MultivacAgent.Job{} = job, attrs) do
    job
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete_job(%MultivacAgent.Job{} = job) do
    Repo.delete(job)
  end

  def change_job(%MultivacAgent.Job{} = job, attrs \\ %{}) do
    changeset(job, attrs)
  end

  def mark_job_as_running(%MultivacAgent.Job{} = job) do
    update_job(job, %{status: "running"})
  end

  def mark_job_as_completed(%MultivacAgent.Job{} = job, result) do
    update_job(job, %{status: "completed", result: result})
  end

  def mark_job_as_failed(%MultivacAgent.Job{} = job, error_message) do
    update_job(job, %{status: "failed", result: error_message})
  end
end
