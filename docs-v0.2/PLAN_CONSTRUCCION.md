# Plan de Construcción Backend — Taco'Os v0.2 (Fase I)

## Filosofía
1 pieza a la vez. Cada pieza se compila y se entiende antes de pasar a la siguiente.
Tú decides nombres, estructura y orden. Yo propongo, tú dispones.
**Construcción ascendente: auth → negocio → productos → transacciones.**

---

## Las 25 Piezas (Endpoints del contrato)

| # | Pieza | Endpoint | Estado |
|---|-------|----------|--------|
| 1 | Foundation | — (pom.xml, entidades base, helpers, exceptions) | ✅ |
| 2 | Auth verificar | `GET /api/v1/auth/verificar/{idGoogle}` | ✅ |
| 3 | Auth registrar | `POST /api/v1/auth/registrar` | ✅ |
| 4 | Negocio crear | `POST /api/v1/business` | ✅ |
| 5 | Negocio detalle | `GET /api/v1/business/{id}` | ✅ |
| 6 | Negocio editar | `PUT /api/v1/business/{id}` | ✅ |
| 7 | Negocio listar cajeros | `GET /api/v1/business/{id}/cajeros` | ✅ |
| 8 | Invitación QR | `POST /api/v1/business/invitation` | ✅ |
| 9 | Enlace cajero | `POST /api/v1/business/link` | ✅ |
| 10 | Producto crear | `POST /api/v1/business/{id}/products` | ✅ |
| 11 | Producto listar | `GET /api/v1/business/{id}/products` | ✅ |
| 12 | Producto editar | `PUT /api/v1/business/{id}/products/{id}` | ✅ |
| 13 | Producto eliminar | `DELETE /api/v1/business/{id}/products/{id}` | ✅ |
| 14 | Apertura caja | `POST /api/v1/cashier/open-session` | ✅ |
| 15 | Transacción venta | `POST /api/v1/transactions` | ✅ |
| 16 | Corte caja | `POST /api/v1/cashier/close-session` | ✅ |
| 17 | Cancelación | `POST /api/v1/transactions/{id}/cancel` | ✅ |
| 18 | Sync batch | `POST /api/v1/sync` | ✅ |
| 19 | Reporte cajas abiertas | `GET /api/v1/business/{id}/reports/open-sessions` | ✅ |
| 20 | Reporte cortes | `GET /api/v1/business/{id}/reports/cuts` | ✅ |
| 21 | Reporte estadísticas | `GET /api/v1/business/{id}/reports/stats` | ✅ |
| 22 | Notificaciones GET | `GET /api/v1/business/{id}/notifications` | ✅ |
| 23 | Notificaciones DELETE | `DELETE /api/v1/business/{id}/notifications/{id}` | ✅ |
| 24 | Planes GET | `GET /api/v1/plans` | ✅ |
| 25 | Licencia + Upgrade + Trial | `GET /api/v1/business/{id}/license`, `POST .../upgrade`, `POST .../trial` | ✅ |

---

## Archivos por Pieza

Cada pieza produce estos archivos (cuando aplique):

- `domain/{entidad}/{Entidad}.java` — Entidad JPA
- `repository/{Entidad}Repository.java` — Spring Data
- `domain/{entidad}/dto/Datos{*}Request/Response.java` — DTOs (records)
- `domain/{entidad}/mapper/{Entidad}Mapper.java` — MapStruct
- `services/{Entidad}Service.java` — Clase concreta (sin interfaz)
- `controller/{Entidad}Controller.java` — Endpoint REST (máx 4 líneas)
- `common/helper/{Entidad}Helper.java` — Validación (solo cuando se necesite)

---

## Próximo Paso (Pieza #10)

Completar CRUD de productos con endpoints GET/POST/PUT/DELETE bajo `/api/v1/business/{id}/products`.

---

## Historial de Construcción

| Fecha | Piezas | Descripción |
|-------|--------|-------------|
| 2026-06-18 | 1-9 | Foundation, Auth, Negocio, Enlace. Refactor v0.2 completo. |
