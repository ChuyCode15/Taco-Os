CREATE TABLE cancellations (
    id              UUID PRIMARY KEY,
    transaction_id  UUID           NOT NULL,
    cashier_id      UUID           NOT NULL,
    reason          VARCHAR(500)   NOT NULL,
    photo_url       TEXT           NOT NULL,
    cancelled_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (cashier_id) REFERENCES cajeros(id)
);
