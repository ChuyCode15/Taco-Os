CREATE TABLE negocios (
    id             UUID PRIMARY KEY,
    name           VARCHAR(255)   NOT NULL,
    address        VARCHAR(255)   NOT NULL,
    phone          VARCHAR(50)    NOT NULL,
    category       VARCHAR(255),
    closing_time   VARCHAR(50),
    currency       VARCHAR(10)    NOT NULL DEFAULT 'MXN',
    base_money     DECIMAL(19, 2),
    employees      INT,
    is_active      BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);
