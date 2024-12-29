defmodule MultivacAgent.JobProcessor do
  use GenServer
  require Logger
  alias MultivacAgent.{Repo, Job}

  @poll_interval 1000 # 1 second

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, state) do
    process_next_job()
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp process_next_job do
    case Job.poll_job() do
      {:ok, %{msg_id: msg_id, data: data}} when not is_nil(data) ->
        Logger.info("Processing job #{msg_id}: #{inspect(data)}")
        try do
          result = execute_command(data["command"])
          Logger.info("Job #{msg_id} completed successfully: #{inspect(result)}")
          case Job.delete_job(msg_id) do
            {:ok, _} ->
              Logger.info("Successfully deleted job #{msg_id}")
            {:error, error} ->
              Logger.error("Failed to delete job #{msg_id}: #{inspect(error)}")
          end
        rescue
          e ->
            Logger.error("Error processing job #{msg_id}: #{inspect(e)}")
            case Job.archive_job(msg_id) do
              {:ok, _} ->
                Logger.info("Archived failed job #{msg_id}")
              {:error, error} ->
                Logger.error("Failed to archive job #{msg_id}: #{inspect(error)}")
            end
        end
      {:ok, nil} ->
        :ok
      {:error, error} ->
        Logger.error("Error polling job: #{inspect(error)}")
    end
  end

  defp execute_command(command) do
    try do
      {result, 0} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)
      result
    rescue
      e ->
        Logger.error("Error executing command: #{inspect(e)}")
        raise e
    end
  end
end
