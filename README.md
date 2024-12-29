# Multivac

Elixir agent receives instructions from postgres via pgmq

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `multivac` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:multivac, "~> 0.1.0"}
  ]
end
```

(Create a project on https://supabasecom and enable pgmq)

## Init
```bash
nix develop
dbmate up
SELECT pgmq.send('job_queue', '{"command": "echo hello"}'::jsonb);
```
## Run in dev

```bash
mix deps.get
iex -S mix
[ ... ]
12:36:46.750 [info] Processing job 40: %{"command" => "echo hello"}

12:36:46.766 [info] Job 40 completed successfully: "hello\n"

12:36:46.849 [debug] QUERY OK db=42.6ms queue=40.5ms idle=739.6ms
SELECT pgmq.delete('job_queue', $1::bigint) [40]

12:36:46.849 [info] Successfully deleted job 40

iex(1)> 
```