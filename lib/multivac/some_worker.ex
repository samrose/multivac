defmodule Multivac.SomeWorker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(job) do
    # Do some work
    IO.puts("Processing value: #{job.args["args"]}")
    :ok
  end
end
