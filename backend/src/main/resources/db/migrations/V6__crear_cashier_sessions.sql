CREATE TABLE cashier_sessions (
    id             UUID PRIMARY KEY,
    business_id    UUID           NOT NULL,
    cashier_id     UUID           NOT NULL,
    device_id      VARCHAR(255),
    opening_balance DECIMAL(19,2) NOT NULL,
    closing_balance DECIMAL(19,2),
    status         VARCHAR(50)    NOT NULL DEFAULT 'ABIERTA',
    opened_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at      TIMESTAMP,
    is_synced      BOOLEAN        NOT NULL DEFAULT FALSE,
    FOREIGN KEY (business_id) REFERENCES negocios(id),
    FOREIGN KEY (cashier_id) REFERENCES cajeros(id)
);
