# Registro de Usuario y Roadmap Fase 1 - Taco OS

## 1. Flujo Detallado de Registro e Identidad

Para garantizar la seguridad y la correcta asignación de datos (Tenant/Business), el flujo de registro sigue estos pasos críticos:

### A. Autenticación Inicial (OAuth2)
1. El usuario inicia sesión con **Google Sign-In**.
2. La App obtiene el `idGoogle`, `email` y `nickname`.
3. Se consulta el endpoint `GET /api/v1/auth/verificar/{idGoogle}`.
   - **Caso Nuevo:** Si no existe, se redirige a "Selección de Rol".
   - **Caso Existente:** Se descarga el `tenantId` y `negocioId` y se entra al Dashboard.

### B. Selección de Rol y Registro
1. El usuario elige entre **Dueño** o **Cajero**.
2. Se envía `POST /api/v1/auth/registrar`.
   - Si es **Dueño**: El sistema crea un `tenantId` único.
   - Si es **Cajero**: Se le solicita el código de vinculación (QR o Texto).

### C. Configuración de Negocio (Solo Dueño)
1. El dueño completa los datos del establecimiento (`nombre`, `dirección`, `moneda`).
2. Se envía `POST /api/v1/business`. El servidor responde con el `businessId`.
3. La App guarda estos datos en la tabla local `business` para operación offline.

---

## 2. Checklist Fase 1: Cierre de Persistencia y Core

Para considerar la **Fase 1 (MVP - Persistencia y Sincronización)** como completada, debemos validar los siguientes puntos:

### [X] Estructura de Datos (Core)
- [X] Entidades Room con soporte ACID (FKs, Cascading).
- [X] "Estampado" de precios en `SaleDetail` para inmutabilidad.
- [X] Tabla de `Cancellations` con soporte para evidencia fotográfica.
- [X] Sistema de Metadata para control de limpieza (Pruning).

### [X] Motor de Sincronización (Sync)
- [X] `SyncWorker` configurado para ejecución cada 15 min.
- [X] Lógica de envío en Batch (Cortes, Ventas, Gastos).
- [X] Mecanismo de subida de imágenes para gastos.
- [X] Limpieza automática de datos sincronizados > 24h.

### [ ] Interfaz de Usuario Crítica (UI Core)
- [ ] **Pantalla de Ventas:** Selección de productos y generación de `SaleNote` + `SaleDetails`.
- [ ] **Control de Caja:** Botones para "Abrir Corte" e "Imprimir/Cerrar Corte".
- [ ] **Módulo de Gastos:** Cámara para capturar tickets y registrar descripción/monto.
- [ ] **Dashboard de Reportes Local:** Vista rápida de ventas del día/turno actual.

---

## 3. Próximos Pasos Inmediatos (Acción)

1. **Integración de Cámara:** Implementar `ActivityResultLauncher` para capturar fotos de gastos y guardarlas en `Internal Storage` antes de que el `SyncWorker` las suba.
2. **Lógica de Transacción Local:** Crear un `SalesRepository` que use `@Transaction` de Room para asegurar que una venta se guarde completa (Nota + Detalles) sin riesgo de datos parciales.
3. **Manejo de Estados de Red:** Implementar un indicador visual en la UI que muestre si hay datos pendientes de sincronizar (ej: icono de nube con contador).

---
*Documento generado para el control de avance del proyecto Taco OS POC.*
