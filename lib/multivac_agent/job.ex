defmodule MultivacAgent.Job do
  alias MultivacAgent.Repo

  def poll_job do
    case Repo.query(
      "SELECT * FROM pgmq.read('job_queue', 30, 1)",
      []
    ) do
      {:ok, %{rows: [[msg_id, _read_ct, _enqueued_at, _vt, message]]}} ->
        {:ok, %{msg_id: msg_id, data: message}}
      {:ok, %{rows: []}} ->
        {:ok, nil}
      {:error, error} ->
        {:error, error}
    end
  end

  def delete_job(msg_id) do
    Repo.query("SELECT pgmq.delete('job_queue', $1::bigint)", [msg_id])
  end

  def archive_job(msg_id) do
    Repo.query("SELECT pgmq.archive('job_queue', $1::bigint)", [msg_id])
  end

  def get_queue_stats do
    case Repo.query("SELECT * FROM pgmq.metrics('job_queue')") do
      {:ok, %{rows: [row], columns: columns}} ->
        Enum.zip(columns, row) |> Map.new()
      error ->
        {:error, error}
    end
  end
end
