-- SuperUsuario
INSERT INTO super_usuarios (id, username, password_hash, full_name, email, is_active, created_at) VALUES
('a0000000-0000-0000-0000-000000000001', 'SuperSu', 'AdminSu', 'Super Administrador', 'admin@tacoos.com', TRUE, CURRENT_TIMESTAMP),
('a0000000-0000-0000-0000-000000000002', 'AdminGlobal', 'Pass1234', 'Administrador Global', 'global@tacoos.com', TRUE, CURRENT_TIMESTAMP),
('a0000000-0000-0000-0000-000000000003', 'SoporteTacoOs', 'Soporte2025', 'Equipo de Soporte', 'soporte@tacoos.com', TRUE, CURRENT_TIMESTAMP),
('a0000000-0000-0000-0000-000000000004', 'DevOpsTaco', 'DevOpsPass', 'DevOps Lead', 'devops@tacoos.com', TRUE, CURRENT_TIMESTAMP),
('a0000000-0000-0000-0000-000000000005', 'AuditorSu', 'AuditorPass', 'Auditor General', 'auditor@tacoos.com', TRUE, CURRENT_TIMESTAMP);

-- Negocios
INSERT INTO negocios (id, name, address, phone, category, closing_time, currency, base_money, employees, is_active, created_at) VALUES
('b0000000-0000-0000-0000-000000000001', 'Tacos El Güero', 'Av. Revolución 1234, Centro', '+521234567890', 'Tacos al pastor', '22:00', 'MXN', 500.00, 4, TRUE, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000002', 'Taquería La Esquina', 'Calle Hidalgo 567, Norte', '+521234567891', 'Tacos de canasta', '23:00', 'MXN', 800.00, 6, TRUE, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000003', 'Tacos Don Pepe', 'Blvd. Insurgentes 890, Sur', '+521234567892', 'Tacos de birria', '00:00', 'MXN', 300.00, 3, TRUE, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000004', 'El Rincón del Sabor', 'Calle Morelos 321, Oeste', '+521234567893', 'Tacos de adobada', '21:00', 'MXN', 600.00, 5, TRUE, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000005', 'Tacos La Abuela', 'Av. Juárez 456, Centro', '+521234567894', 'Tacos de guisado', '20:00', 'MXN', 450.00, 3, TRUE, CURRENT_TIMESTAMP);

-- Administradores
INSERT INTO administradores (id, google_id, full_name, nickname, email, phone, business_id, plan_type, plan_status, due_date, is_active, created_at) VALUES
('c0000000-0000-0000-0000-000000000001', 'ggl_1001', 'Juan Pérez', 'JuanTacos', 'juan@tacos.com', '+521234567801', 'b0000000-0000-0000-0000-000000000001', 'PREMIUM', 'PAGADO', '2025-12-31', TRUE, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000002', 'ggl_1002', 'María López', 'MariTacos', 'maria@tacos.com', '+521234567802', 'b0000000-0000-0000-0000-000000000002', 'BUSINESS', 'PAGADO', '2025-06-30', TRUE, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000003', 'ggl_1003', 'Carlos García', 'Carlitos', 'carlos@tacos.com', '+521234567803', 'b0000000-0000-0000-0000-000000000003', 'FREE', 'TRIAL_PREMIUM', '2025-02-15', TRUE, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000004', 'ggl_1004', 'Ana Martínez', 'AnaTacos', 'ana@tacos.com', '+521234567804', 'b0000000-0000-0000-0000-000000000004', 'PREMIUM', 'PAGADO', '2025-09-30', TRUE, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000005', 'ggl_1005', 'Roberto Díaz', 'RobTacos', 'roberto@tacos.com', '+521234567805', 'b0000000-0000-0000-0000-000000000005', 'BUSINESS', 'VENCIDO', '2025-01-01', TRUE, CURRENT_TIMESTAMP);

-- Cajeros
INSERT INTO cajeros (id, google_id, full_name, nickname, email, phone, business_id, permissions, linked_at, is_active, created_at) VALUES
('d0000000-0000-0000-0000-000000000001', 'ggl_2001', 'Pedro Sánchez', 'PedroCajero', 'pedro@cajeros.com', '+521234567811', 'b0000000-0000-0000-0000-000000000001', 'VENTAS,CONSUMO', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000002', 'ggl_2002', 'Laura Hernández', 'LauraCajero', 'laura@cajeros.com', '+521234567812', 'b0000000-0000-0000-0000-000000000001', 'VENTAS,CONSUMO', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000003', 'ggl_2003', 'Miguel Torres', 'MiguelCajero', 'miguel@cajeros.com', '+521234567813', 'b0000000-0000-0000-0000-000000000002', 'VENTAS', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000004', 'ggl_2004', 'Sofía Ramírez', 'SofiCajero', 'sofia@cajeros.com', '+521234567814', 'b0000000-0000-0000-0000-000000000003', 'VENTAS,CONSUMO', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000005', 'ggl_2005', 'Fernando Cruz', 'FerCajero', 'fernando@cajeros.com', '+521234567815', 'b0000000-0000-0000-0000-000000000004', 'VENTAS', CURRENT_TIMESTAMP, TRUE, CURRENT_TIMESTAMP);

-- Productos
INSERT INTO productos (id, name, price, category, photo_url, business_id, is_active, created_at) VALUES
('e0000000-0000-0000-0000-000000000001', 'Taco al Pastor', 15.00, 'COMIDA', 'https://storage.tacoos.com/taco-pastor.jpg', 'b0000000-0000-0000-0000-000000000001', TRUE, CURRENT_TIMESTAMP),
('e0000000-0000-0000-0000-000000000002', 'Taco de Birria', 18.00, 'COMIDA', 'https://storage.tacoos.com/taco-birria.jpg', 'b0000000-0000-0000-0000-000000000002', TRUE, CURRENT_TIMESTAMP),
('e0000000-0000-0000-0000-000000000003', 'Coca-Cola 600ml', 20.00, 'BEBIDAS', 'https://storage.tacoos.com/coca.jpg', 'b0000000-0000-0000-0000-000000000001', TRUE, CURRENT_TIMESTAMP),
('e0000000-0000-0000-0000-000000000004', 'Taco de Canasta', 12.00, 'COMIDA', 'https://storage.tacoos.com/taco-canasta.jpg', 'b0000000-0000-0000-0000-000000000003', TRUE, CURRENT_TIMESTAMP),
('e0000000-0000-0000-0000-000000000005', 'Agua de Horchata', 15.00, 'BEBIDAS', 'https://storage.tacoos.com/horchata.jpg', 'b0000000-0000-0000-0000-000000000004', TRUE, CURRENT_TIMESTAMP);

-- Licencias
INSERT INTO licenses (id, business_id, plan, status, start_date, end_date, trial_end_date, max_businesses, max_cashiers, features, created_at) VALUES
('f0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'PREMIUM', 'PAGADO', '2025-01-01', '2025-12-31', NULL, 3, 10, 'REPORTES,INVENTARIO,NOTIFICACIONES', CURRENT_TIMESTAMP),
('f0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'BUSINESS', 'PAGADO', '2025-01-15', '2025-06-30', NULL, 5, 20, 'REPORTES,INVENTARIO,NOTIFICACIONES,API', CURRENT_TIMESTAMP),
('f0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000003', 'FREE', 'TRIAL_PREMIUM', '2025-01-10', '2025-04-10', '2025-02-10', 1, 2, 'BASICO', CURRENT_TIMESTAMP),
('f0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000004', 'PREMIUM', 'PAGADO', '2025-02-01', '2025-09-30', NULL, 3, 10, 'REPORTES,INVENTARIO', CURRENT_TIMESTAMP),
('f0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000005', 'BUSINESS', 'VENCIDO', '2024-06-01', '2025-01-01', NULL, 5, 20, 'REPORTES,INVENTARIO,NOTIFICACIONES,API', CURRENT_TIMESTAMP);
