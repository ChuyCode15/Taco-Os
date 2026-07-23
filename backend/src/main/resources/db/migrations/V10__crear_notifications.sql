CREATE TABLE notifications (
    id             UUID PRIMARY KEY,
    business_id    UUID           NOT NULL,
    type           VARCHAR(50)    NOT NULL,
    message        VARCHAR(500)   NOT NULL,
    data_json      TEXT,
    is_read        BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES negocios(id)
);
