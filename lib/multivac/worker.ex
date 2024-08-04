defmodule Multivac.Worker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(job) do
    %{"args" => %{"some_field" => value}} = job.args
    # Do some work with the value of some_field
    IO.puts("Processing value: #{value}")
    :ok
  end
end
