defmodule MultivacAgent.JobProcessor do
  use GenServer
  require Logger
  alias MultivacAgent.{Repo, Job}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    {:ok, _} = Postgrex.Notifications.start_link(MultivacAgent.Repo.config())
    |> tap(fn {:ok, pid} -> Postgrex.Notifications.listen(pid, "job_changes") end)

    Logger.info("Listening for job_changes notifications")
    {:ok, state}
  end

  def handle_info({:notification, _pid, _ref, "job_changes", payload}, state) do
    Logger.info("Received notification on job_changes channel: #{payload}")
    [operation, job_id] = String.split(payload)
    process_job_change(operation, job_id)
    {:noreply, state}
  end

  defp process_job_change("INSERT", job_id) do
    job_id
    |> String.to_integer()
    |> Job.get_job!()
    |> process_job()
  end

  defp process_job_change("UPDATE", job_id) do
    job_id
    |> String.to_integer()
    |> Job.get_job!()
    |> maybe_process_job()
  end

  defp process_job_change("DELETE", _job_id) do
    # Handle delete operation if needed
    Logger.info("Job deleted")
  end

  defp maybe_process_job(job) do
    if job.status == "pending" do
      process_job(job)
    end
  end

  defp process_job(job) do
    case Job.mark_job_as_running(job) do
      {:ok, job} ->
        result = execute_command(job.command)
        Job.mark_job_as_completed(job, result)
      {:error, _changeset} ->
        Logger.error("Failed to mark job as running: #{job.id}")
    end
  end

  defp execute_command(command) do
    try do
      {result, 0} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)
      result
    rescue
      e ->
        Logger.error("Error executing command: #{inspect(e)}")
        "Error: #{inspect(e)}"
    end
  end
end
