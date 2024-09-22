# Multivac

**TODO: Add description**

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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/example>.

## DB Setup

```sql
-- Create the jobs table
CREATE TABLE jobs (
    id SERIAL PRIMARY KEY,
    command TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    result TEXT,
    inserted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create the job_change_log table
CREATE TABLE job_change_log (
    id SERIAL PRIMARY KEY,
    job_id INTEGER,
    changed_at TIMESTAMP,
    operation TEXT,
    old_values JSONB,
    new_values JSONB
);

-- Create the log_job_changes function with notification
CREATE OR REPLACE FUNCTION log_job_changes() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO job_change_log (job_id, changed_at, operation, new_values)
        VALUES (NEW.id, NOW(), TG_OP, row_to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO job_change_log (job_id, changed_at, operation, old_values, new_values)
        VALUES (NEW.id, NOW(), TG_OP, row_to_json(OLD), row_to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO job_change_log (job_id, changed_at, operation, old_values)
        VALUES (OLD.id, NOW(), TG_OP, row_to_json(OLD));
    END IF;

    -- Send notification
    PERFORM pg_notify('job_changes', TG_OP || ' ' || COALESCE(NEW.id::text, OLD.id::text));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on the jobs table for logging changes and sending notifications
CREATE TRIGGER job_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON jobs
FOR EACH ROW EXECUTE FUNCTION log_job_changes();

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_jobs_updated_at
BEFORE UPDATE ON jobs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create index on the status column for faster queries
CREATE INDEX idx_jobs_status ON jobs(status);

-- Create index on the job_id column in job_change_log for faster queries
CREATE INDEX idx_job_change_log_job_id ON job_change_log(job_id);
```