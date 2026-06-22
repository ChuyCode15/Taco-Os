CREATE TABLE master_tickets (
    id              UUID PRIMARY KEY,
    client_id       UUID NOT NULL,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    priority        VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    status          VARCHAR(20) NOT NULL DEFAULT 'ABIERTO',
    assigned_to     UUID,
    created_by      UUID NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     TIMESTAMP
);
