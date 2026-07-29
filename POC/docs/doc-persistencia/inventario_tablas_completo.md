# Inventario Completo de Tablas y Entidades (App & Backend)

Este documento clasifica todas las estructuras de datos necesarias para Taco'Os, separándolas por su segmento de control y estado actual de implementación.

---

## 1. Segmento de Identidad y Acceso (Auth)
*Gestión de usuarios, roles y vinculación con Google.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `users` | Local | **Existente** | Perfil del usuario logueado en el dispositivo. |
| `users` (Mongo/SQL) | Backend | **Existente** | Maestro de identidades y roles globales. |
| `invitations` | Backend | **Existente** | Registro de códigos QR para vincular cajeros a negocios. |
| `user_sessions` | Backend | **Pendiente** | Historial de dispositivos desde donde se ha logueado el usuario. |

---

## 2. Segmento de Operación POS (Ventas y Gastos)
*Transacciones diarias y auditoría inmediata.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `sales` | Local | **Existente (v7)** | Ventas offline con ruta de imagen de voucher. |
| `expenses` | Local | **Existente (v7)** | Gastos offline con ruta de imagen de ticket. |
| `sales` | Backend | **Parcial** | Registro consolidado para reportes web del dueño. |
| `expenses` | Backend | **Pendiente** | Registro consolidado de egresos. |
| `sale_items` | Backend | **Pendiente** | Tabla relacional para desglosar productos vendidos (si no se usa JSON). |

---

## 3. Segmento de Control de Efectivo (Turnos)
*Arqueos de caja y responsabilidad financiera.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `shift_manager` | Local | **Memoria** | Actualmente solo vive en RAM. Se pierde al cerrar app. |
| `cash_sessions` | Local | **FALTA** | Persistencia física de aperturas y cierres de caja históricos. |
| `cash_sessions` | Backend | **Parcial** | Endpoints de open/close session iniciados. |
| `cash_adjustments` | Ambos | **FALTA** | Registro de entradas/salidas de dinero que no son ventas ni gastos. |

---

## 4. Segmento de Catálogo (Productos)
*Administración de lo que se vende.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `products` | Local | **Existente (v7)** | Catálogo con imágenes y categorías. |
| `products` | Backend | **Parcial** | Endpoints base creados, falta sincronización bidireccional. |
| `categories` | Ambos | **Mock** | Actualmente hardcodeado (Comidas, Bebidas, Postres). Debe ser tabla. |

---

## 5. Segmento de Control Maestro (Licencias y Config)
*Supervisión del ecosistema Taco'Os.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `app_metadata` | Local | **Existente** | Timestamp de última sincronización y validez de licencia. |
| `licenses` | Backend | **Existente** | Maestro de suscripciones por negocio. |
| `business_config` | Ambos | **FALTA** | Configuración de moneda, % propinas sugeridas, tiques de impresión. |

---

## 6. Segmento de Asistencia y Reportes al Cliente
*Comunicación directa y soporte técnico.*

| Tabla / Entidad | Nivel | Estado | Propósito |
| :--- | :--- | :--- | :--- |
| `support_tickets` | Ambos | **FALTA** | Hilo de conversación entre usuario y Taco'Os Soporte. |
| `incident_logs` | Local | **FALTA** | Captura automática de errores 403/500 para diagnóstico remoto. |
| `system_messages` | Local | **FALTA** | Avisos globales (ej: "Mantenimiento programado el domingo"). |
| `push_tokens` | Backend | **Pendiente** | Registro de tokens FCM para notificaciones al celular. |

---

## Resumen de Acción Inmediata (Prioridad Alta)
1.  **Migrar `shift_manager` (Memoria) a `cash_sessions` (Room):** Es el hueco más grande de persistencia actual.
2.  **Crear `support_tickets`:** Para habilitar el canal de comunicación con el cliente.
3.  **Implementar `incident_logs`:** Para que el botón de "Reportar Fallo" envíe datos reales del problema técnico.
