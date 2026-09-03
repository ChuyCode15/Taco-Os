CREATE TABLE venta_items (
    id              BIGSERIAL PRIMARY KEY,
    transaction_id  UUID NOT NULL,
    producto        VARCHAR(255) NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(19,2) NOT NULL,
    total           DECIMAL(19,2) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);