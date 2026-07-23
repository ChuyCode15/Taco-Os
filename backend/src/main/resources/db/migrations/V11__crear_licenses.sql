CREATE TABLE licenses (
    id             UUID PRIMARY KEY,
    business_id    UUID           NOT NULL UNIQUE,
    plan           VARCHAR(50)    NOT NULL DEFAULT 'FREE',
    status         VARCHAR(50)    NOT NULL DEFAULT 'PAGADO',
    start_date     DATE           NOT NULL,
    end_date       DATE,
    trial_end_date DATE,
    max_businesses INT            NOT NULL DEFAULT 1,
    max_cashiers   INT            NOT NULL DEFAULT 2,
    features       TEXT,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES negocios(id)
);
