CREATE TABLE cajeros (
    id             UUID PRIMARY KEY,
    google_id      VARCHAR(255)  NOT NULL UNIQUE,
    full_name      VARCHAR(255)  NOT NULL,
    nickname       VARCHAR(100),
    email          VARCHAR(255)  NOT NULL,
    phone          VARCHAR(50),
    business_id    UUID,
    permissions    TEXT,
    linked_at      TIMESTAMP,
    is_active      BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES negocios(id)
);
