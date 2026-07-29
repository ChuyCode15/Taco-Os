# Análisis Técnico de Persistencia Completa - Taco'Os POC

Este documento detalla el estado actual y el diseño necesario para garantizar una persistencia 100% fiable entre la Aplicación Móvil, el Backend y el Control Maestro.

## 1. Arquitectura de Dos Niveles (App vs Backend)

### Nivel 1: Persistencia Local (App - SQLite/Room)
*   **Propósito:** Garantizar operatividad Offline, velocidad de respuesta y seguridad de datos inmediata.
*   **Estado Actual:**
    *   `users`: Perfil del usuario activo y su token JWT.
    *   `business`: Datos del establecimiento y dinero base.
    *   `sales`: Transacciones con soporte para auditoría (método, items, foto de voucher).
    *   `expenses`: Gastos operativos con foto de ticket.
    *   `products`: Catálogo real con imágenes locales.
    *   `app_metadata`: Control de sesiones de 12h y validez de licencia (24h offline).

### Nivel 2: Persistencia en la Nube (Backend - MongoDB/SQL)
*   **Propósito:** Consolidación de datos de múltiples sucursales, reportes maestros para el dueño y respaldo histórico.
*   **Contratos Actuales (API):**
    *   `api/v1/auth`: Gestión de identidades Google.
    *   `api/v1/business`: Registro y configuración de establecimientos.
    *   `api/v1/sync`: Endpoint maestro para subir ráfagas (batches) de ventas y gastos.
    *   `api/v1/cashier`: Apertura y cierre de turnos vinculados a un responsable.

---

## 2. Matriz de Datos para Persistencia Óptima

Para obtener reportes limpios y auditoría total, la siguiente estructura debe estar sincronizada:

| Entidad | Datos Críticos para Reportes Históricos | Estado App | Estado Backend |
| :--- | :--- | :--- | :--- |
| **Ventas** | Monto, Fecha/Hora, Cajero (ID), Items (JSON), Método de Pago, Voucher (Foto), Estatus (Cobrada/Cancelada). | Completo (Room v7) | Parcial (SaleRequest) |
| **Gastos** | Detalle, Monto, Cajero, Ticket (Foto), Fecha/Hora. | Completo (Room v7) | Pendiente (SyncBatch) |
| **Inventario** | Nombre, Precio, Categoría, Historial de cambios de precio. | Funcional | Pendiente CRUD Nube |
| **Cortes** | Fondo inicial, Efectivo real al cierre, Diferencia, Responsable, Fecha/Hora Apertura/Cierre. | Parcial (Memoria) | Pendiente (CloseSession) |

---

## 3. Integración con Control Maestro

El **Control Maestro** es el cerebro que supervisa todas las sucursales. Su persistencia debe incluir:

1.  **Estado de Licencias:**
    *   Sincronización cada 24 horas.
    *   La app debe guardar el `lastMasterSyncTimestamp`. Si excede las 24h sin internet, el sistema bloquea funciones operativas pero mantiene la visualización.
2.  **Configuración Global:**
    *   Moneda, impuestos y reglas de redondeo enviadas desde el Maestro hacia las apps.

---

## 4. Sistema de Mensajería y Soporte

Para una asistencia eficiente al cliente, se requiere:

*   **Logs de Incidencias:** Guardar localmente los errores HTTP (como el 403 o 409 detectados) para que el cliente pueda enviarlos con un botón de "Reportar Fallo".
*   **Notificaciones Push:** El Backend debe persistir un `fcmToken` por dispositivo para enviar alertas de "Cierre de Turno" o "Licencia por Vencer".
*   **Tiquets de Asistencia:** Persistencia de mensajes entre el cajero/dueño y el soporte técnico dentro de la misma app.

---

## 5. Estrategia de Imágenes (Consolidada)

Para no degradar el rendimiento, la persistencia de imágenes seguirá este flujo:

1.  **Captura:** Se guarda como archivo `.jpg` en la carpeta interna privada de la app.
2.  **Referencia:** Room solo guarda la ruta String (`imagePath`).
3.  **Subida:** El `SyncWorker` utiliza `MultipartFormData` para enviar la imagen al Backend.
4.  **Almacenamiento Cloud:** El Backend guarda la imagen en un Bucket (S3/GCS) y persiste la URL pública para los reportes web del cliente.

---

## 6. Discrepancias Detectadas (Gaps)

1.  **Cierre de Turno:** La UI calcula el cierre perfectamente (`CorteDialog`), pero esa "foto final" del corte no se está guardando en una tabla `sessions` o `cortes` en Room; solo se limpian las ventas. **Acción recomendada:** Crear entidad `SessionSummary`.
2.  **Auditoría de Precios:** Si un producto cambia de precio hoy, las ventas de ayer no deben verse afectadas. El `productsJson` en la venta resuelve esto, pero hay que asegurar que el Backend también guarde el "Precio Histórico" en el momento de la transacción.
3.  **Mensajería:** No existe tabla local ni endpoint para la comunicación de soporte técnico.

---
**Análisis Técnico realizado para Taco'Os POC v1.0**
