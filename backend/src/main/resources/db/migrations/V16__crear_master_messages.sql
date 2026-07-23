CREATE TABLE master_messages (
    id              UUID PRIMARY KEY,
    ticket_id       UUID NOT NULL,
    sender_id       UUID NOT NULL,
    sender_type     VARCHAR(20) NOT NULL,
    content         TEXT NOT NULL,
    attachment_url  VARCHAR(500),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
