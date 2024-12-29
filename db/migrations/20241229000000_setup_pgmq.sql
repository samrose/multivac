-- migrate:up
-- Check if we can use existing pgmq
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pgmq'
    ) THEN
        RAISE EXCEPTION 'PGMQ extension is not installed in this database';
    END IF;
END
$$;

-- Create our queue in the public schema
SELECT pgmq.create('job_queue');

-- Create improved jobs table in the public schema
CREATE TABLE public.jobs (
    id BIGSERIAL PRIMARY KEY,
    command TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    result TEXT,
    inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create function to update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON public.jobs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX idx_jobs_status ON public.jobs(status);

-- migrate:down
DROP TRIGGER IF EXISTS update_jobs_updated_at ON public.jobs;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP TABLE IF EXISTS public.jobs;
SELECT pgmq.drop('job_queue');
