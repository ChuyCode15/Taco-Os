# Plan de Construcción Backend Taco'Os — Fase I

## Filosofía
1 pieza a la vez. Cada pieza se compila y se entiende antes de pasar a la siguiente.
Tú decides nombres, estructura y orden. Yo propongo, tú dispones.

## Las 25 Piezas (Endpoints del contrato)

| # | Pieza | Endpoint | Depende de |
|---|-------|----------|-----------|
| 1 | Foundation | — | — |
| 2 | Product (GET list, POST create) | `/api/v1/business/{id}/products` | Foundation |
| 3 | Product (PUT update, DELETE) | `/api/v1/business/{id}/products/{id}` | #2 |
| 4 | Auth Login | `POST /api/v1/auth/login` | #1 |
| 5 | Auth Role | `PUT /api/v1/auth/role` | #4 |
| 6 | Business CRUD | `POST /api/v1/business` | #4 |
| 7 | Open Session | `POST /api/v1/cashier/open-session` | #4, #6 |
| 8 | Transaction (venta efectivo) | `POST /api/v1/transactions` | #7 |
| 9 | Transaction (venta tarjeta) | `POST /api/v1/transactions` (mismo) | #8 |
| 10 | Transaction (gasto) | `POST /api/v1/transactions` (mismo) | #8 |
| 11 | Close Session / Corte | `POST /api/v1/cashier/close-session` | #7, #8 |
| 12 | Cancelación | `POST /api/v1/transactions/{id}/cancel` | #8 |
| 13 | QR Invitación | `POST /api/v1/business/{id}/cashiers/invitation` | #6 |
| 14 | Link Cajero | `POST /api/v1/business/link-cashier` | #4, #13 |
| 15 | Lista Cajeros | `GET /api/v1/business/{id}/cashiers` | #6 |
| 16 | Desvincular Cajero | `DELETE /api/v1/business/{id}/cashiers/{id}` | #6 |
| 17 | Reporte Cajas Abiertas | `GET /api/v1/business/{id}/reports/open-sessions` | #7 |
| 18 | Reporte Lista de Cortes | `GET /api/v1/business/{id}/reports/cuts` | #11 |
| 19 | Reporte Estadísticas | `GET /api/v1/business/{id}/reports/stats` | #8 |
| 20 | Notificaciones GET | `GET /api/v1/business/{id}/notifications` | #1 |
| 21 | Notificaciones DELETE | `DELETE /api/v1/business/{id}/notifications/{id}` | #20 |
| 22 | Planes GET | `GET /api/v1/plans` | #1 |
| 23 | Licencia GET | `GET /api/v1/business/{id}/license` | #6 |
| 24 | Upgrade Plan | `POST /api/v1/business/{id}/license/upgrade` | #23 |
| 25 | Trial | `POST /api/v1/business/{id}/license/trial` | #23 |

## Ajustes JMC
---
| # | controller | Endpoint  | Relacion   |
|---|-----------|-----------|------------|
| 1 | productos | registrar | `POST /api/v1/business/{id}/products` |
| 2 | prodcutos | actualizar | `` | 

---

## Archivos por pieza

Cada pieza produce estos archivos (cuando aplique):
- `model/{Entidad}.java` — Entidad JPA
- `repository/{Entidad}Repository.java` — Spring Data
- `dto/request/{*}Request.java` — DTO de entrada
- `dto/response/{*}Response.java` — DTO de salida
- `mapper/{*}Mapper.java` — MapStruct
- `service/{*}Service.java` — Interface
- `service/impl/{*}ServiceImpl.java` — Implementación
- `controller/{*}Controller.java` — Endpoint REST
- `validator/{*}Validator.java` — Validación (solo cuando se necesite)
- `helper/{*}Helper.java` — Utilidad (solo cuando se necesite)

## ¿Por dónde empezamos?

Propongo empezar por la **Pieza #1 (Foundation)** → `pom.xml`, `application.yml`, `TacoOsApplication.java`.

Luego **Pieza #2 (Product GET/POST)** — es la más simple, sin dependencias externas, perfecta para calentar.

Tú eliges el orden. ¿Empezamos?
