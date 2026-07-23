CREATE TABLE master_audit_log (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL,
    action          VARCHAR(100) NOT NULL,
    target_type     VARCHAR(50),
    target_id       UUID,
    details         VARCHAR(2000),
    ip_address      VARCHAR(45),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
