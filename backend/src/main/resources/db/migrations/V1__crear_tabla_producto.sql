CREATE TABLE productos
(
    id             UUID PRIMARY KEY,
    nombre         VARCHAR(255)   NOT NULL,
    precio         DECIMAL(19, 2) NOT NULL,
    categoria      VARCHAR(100)   NOT NULL,
    mini_vista_url VARCHAR(255)
);