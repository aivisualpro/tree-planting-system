CREATE TABLE sync_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_uuid UUID NOT NULL,
    user_id UUID REFERENCES profiles(id),
    operation TEXT NOT NULL,
    status TEXT NOT NULL,
    error_message TEXT,
    attempt_count INT DEFAULT 1,
    server_received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
