defmodule Multivac.TableListener do
  use GenServer
  alias Multivac.Repo
  alias Oban.Job

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    case Postgrex.Notifications.start_link(Repo.config()) do
      {:ok, pid} ->
        ref = Postgrex.Notifications.listen!(pid, "jobs_table_insert_channel")
        {:ok, Map.put(state, :pid, pid) |> Map.put(:ref, ref)}

      {:error, reason} ->
        IO.puts("Failed to start Postgrex.Notifications: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "jobs_table_insert_channel", payload}, state) do
    handle_table_change(payload)
    {:noreply, state}
  end

  defp handle_table_change(payload) do
    # Decode the payload if necessary
    %{"args" => %{"some_field" => value}} = Jason.decode!(payload)

    %{
      "args" => %{
        "some_field" => value
      }
    }
    |> Job.new(worker: "Multivac.SomeWorker", queue: "default", state: "available", scheduled_at: DateTime.utc_now())
    |> Oban.insert()

    # case Repo.insert(job_changeset) do
    #   {:ok, _job} -> :ok
    #   {:error, changeset} -> IO.inspect(changeset, label: "Failed to insert job")
    # end
  end
end
