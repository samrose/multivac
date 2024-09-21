defmodule MultivacAgent.JobProcessor do
  use GenServer
  alias MultivacAgent.Repo
  alias MultivacAgent.Job
  import Ecto.Query

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_job_check()
    {:ok, state}
  end

  def handle_info(:check_jobs, state) do
    process_pending_jobs()
    schedule_job_check()
    {:noreply, state}
  end

  defp schedule_job_check do
    Process.send_after(self(), :check_jobs, 5000) # Check every 5 seconds
  end

  defp process_pending_jobs do
    Job
    |> where([j], j.status == "pending")
    |> limit(10)
    |> Repo.all()
    |> Enum.each(&process_job/1)
  end

  defp process_job(job) do
    Repo.transaction(fn ->
      job = job |> Repo.preload(:service)
      result = execute_command(job.command)
      
      job
      |> Job.changeset(%{status: "completed", result: result})
      |> Repo.update!()
    end)
  end

  defp execute_command(command) do
    try do
      {result, 0} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)
      result
    rescue
      e in ErlangError ->
        "Error: #{inspect(e)}"
    end
  end
end