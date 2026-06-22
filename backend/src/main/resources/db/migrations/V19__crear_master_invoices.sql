CREATE TABLE master_invoices (
    id              UUID PRIMARY KEY,
    client_id       UUID NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    plan            VARCHAR(50) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
