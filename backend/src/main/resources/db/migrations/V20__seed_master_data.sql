-- Master Users (staff interno)
INSERT INTO master_users (id, username, password_hash, full_name, email, role, is_active, created_at) VALUES
('aa000000-0000-0000-0000-000000000001', 'jesus', 'dev123', 'Jesús Martínez', 'jesus@tacoos.com', 'DEVELOPER', TRUE, CURRENT_TIMESTAMP),
('aa000000-0000-0000-0000-000000000002', 'fanner', 'dev123', 'Fanner García', 'fanner@tacoos.com', 'DEVELOPER', TRUE, CURRENT_TIMESTAMP),
('aa000000-0000-0000-0000-000000000003', 'leandro', 'dev123', 'Leandro Reyes', 'leandro@tacoos.com', 'DATA_SCIENTIST', TRUE, CURRENT_TIMESTAMP),
('aa000000-0000-0000-0000-000000000004', 'soporte1', 'sup123', 'Ana López', 'ana@tacoos.com', 'SOPORTE', TRUE, CURRENT_TIMESTAMP),
('aa000000-0000-0000-0000-000000000005', 'soporte2', 'sup123', 'Carlos Ruiz', 'carlos@tacoos.com', 'SOPORTE', TRUE, CURRENT_TIMESTAMP);

-- Master Tickets
INSERT INTO master_tickets (id, client_id, title, description, priority, status, assigned_to, created_by, created_at, updated_at) VALUES
('bb000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Error en corte diario', 'El corte diario no genera el reporte correctamente', 'ALTA', 'ABIERTO', NULL, 'aa000000-0000-0000-0000-000000000004', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('bb000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'No puede agregar productos', 'El formulario de productos no carga', 'URGENTE', 'EN_PROGRESO', 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000004', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('bb000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', 'Sesión de cajero stuck', 'El cajero no puede cerrar sesión', 'NORMAL', 'RESUELTO', 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000005', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Master Messages
INSERT INTO master_messages (id, ticket_id, sender_id, sender_type, content, created_at) VALUES
('cc000000-0000-0000-0000-000000000001', 'bb000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'CLIENT', 'Hola, el corte diario me sale con error 500', CURRENT_TIMESTAMP),
('cc000000-0000-0000-0000-000000000002', 'bb000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000004', 'STAFF', 'Entendido, voy a revisar. ¿Qué hora tienes configurada en el negocio?', CURRENT_TIMESTAMP),
('cc000000-0000-0000-0000-000000000003', 'bb000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'CLIENT', 'No puedo agregar productos nuevos, el botón no responde', CURRENT_TIMESTAMP);

-- Master Incidents
INSERT INTO master_incidents (id, client_id, title, description, severity, status, detected_by, assigned_to, action_taken, created_at) VALUES
('dd000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Error 500 en corte diario', 'El endpoint /cashier/daily-cut retorna 500 cuando el negocio no tiene productos', 'ALTA', 'EN_REPARACION', 'aa000000-0000-0000-0000-000000000004', 'aa000000-0000-0000-0000-000000000001', NULL, CURRENT_TIMESTAMP),
('dd000000-0000-0000-0000-000000000002', NULL, 'Lentitud en respuesta de login', 'El login tarda más de 5 segundos en responder', 'MEDIA', 'DETECTADA', NULL, NULL, NULL, CURRENT_TIMESTAMP);

-- Master Audit Log
INSERT INTO master_audit_log (id, user_id, action, target_type, target_id, details, ip_address, created_at) VALUES
('ee000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'FORCE_CLOSE_SESSION', 'CLIENT', 'c0000000-0000-0000-0000-000000000003', 'Forzar cierre de sesión del cajero Pedro', '192.168.1.100', CURRENT_TIMESTAMP),
('ee000000-0000-0000-0000-000000000002', 'aa000000-0000-0000-0000-000000000004', 'ASSIGN_TICKET', 'TICKET', 'bb000000-0000-0000-0000-000000000002', 'Ticket asignado a Jesús Martínez', '192.168.1.101', CURRENT_TIMESTAMP);

-- Master Invoices
INSERT INTO master_invoices (id, client_id, amount, plan, status, due_date, created_at) VALUES
('ff000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 99.00, 'PREMIUM', 'PAGADA', '2026-06-30', CURRENT_TIMESTAMP),
('ff000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 49.00, 'BUSINESS', 'PENDIENTE', '2026-06-30', CURRENT_TIMESTAMP),
('ff000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', 0.00, 'FREE', 'PAGADA', '2026-06-30', CURRENT_TIMESTAMP);
