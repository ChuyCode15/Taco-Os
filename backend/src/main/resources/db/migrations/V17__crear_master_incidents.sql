CREATE TABLE master_incidents (
    id              UUID PRIMARY KEY,
    client_id       UUID,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    severity        VARCHAR(20) NOT NULL,
    status          VARCHAR(20) NOT NULL,
    detected_by     UUID,
    assigned_to     UUID,
    action_taken    TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     TIMESTAMP
);
