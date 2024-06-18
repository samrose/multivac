defmodule Multivac.JobStatusListener do
  use GenServer
  alias Multivac.Repo

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    case Postgrex.Notifications.start_link(Repo.config()) do
      {:ok, pid} ->
        ref = Postgrex.Notifications.listen!(pid, "job_status_changes")
        {:ok, Map.put(state, :pid, pid) |> Map.put(:ref, ref)}

      {:error, reason} ->
        IO.puts("Failed to start Postgrex.Notifications: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "job_status_changes", payload}, state) do
    handle_job_status_change(payload)
    {:noreply, state}
  end

  defp handle_job_status_change(payload) do
    # Handle job status change logic
    IO.puts("Job status changed: #{payload}")
  end
end
