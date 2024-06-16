defmodule Multivac.SomeWorker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"some_field" => some_field}}) do
    # Do some work with the value of some_field
    IO.puts("Processing value: #{some_field}")
    :ok
  end
end
