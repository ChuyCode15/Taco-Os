CREATE TABLE productos (
    id             UUID PRIMARY KEY,
    name           VARCHAR(255)   NOT NULL,
    price          DECIMAL(19, 2) NOT NULL,
    category       VARCHAR(100)   NOT NULL,
    photo_url      VARCHAR(500),
    business_id    UUID           NOT NULL,
    is_active      BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES negocios(id)
);
