CREATE TABLE invitaciones (
    id             UUID PRIMARY KEY,
    business_id    UUID           NOT NULL,
    owner_id       UUID           NOT NULL,
    code           VARCHAR(100)   NOT NULL UNIQUE,
    expires_at     TIMESTAMP      NOT NULL,
    is_active      BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);
