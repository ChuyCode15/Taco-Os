# Taco'Os — Asistente de Ventas para Micro-Negocios

> **Misión:** Democratizar la inteligencia financiera para micro-negocios informales.
> **Filosofía:** "Finanzas como el alma del negocio". El sistema es un aliado silencioso: analiza, alerta y sugiere sin abrumar.

---

## Ecosistema

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TACO'OS ECOSISTEMA                           │
├─────────────────────────┬───────────────────────────────────────────┤
│   App Flutter (CJK)     │   Control Maestro (Admin Panel)          │
│   Modo Cajero + Patrón  │   Angular 21 + Material + Tailwind      │
├─────────────────────────┴───────────────────────────────────────────┤
│                     Backend API (Java 21)                           │
│              Spring Boot + Flyway + JWT + WebSocket                 │
├─────────────────────────────────────────────────────────────────────┤
│                  ╔═══════════════════════════╗                      │
│                  ║   BASE DE DATOS           ║                      │
│                  ║   H2 (dev) / PostgreSQL   ║                      │
│                  ╚═══════════════════════════╝                      │
│  negocios | administradores | cajeros | productos | transacciones   │
│  master_users | master_tickets | master_messages | master_incidents │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Stack Técnico

| Capa | Tecnología | Rol |
|------|-----------|-----|
| **App Móvil** | Flutter + SQLite/Room | Base maestra local. 100% operable sin internet. |
| **Control Maestro** | Angular 21 + Material + Tailwind CSS v4 | Panel admin central para el equipo de Taco'Os |
| **Backend** | Spring Boot 3.4 + Java 21 | API REST, autenticación JWT, WebSocket, reportes |
| **DB** | H2 (dev) / PostgreSQL (prod) | Multi-tenant por business_id |
| **Migraciones** | Flyway | Control de esquema (V1–V20) |

---

## Estructura del Proyecto

```
Taco_Os/
├── backend/                          # Spring Boot API
│   ├── src/main/java/com/jmcsoft/taco_os/
│   │   ├── config/                   # SecurityConfig, JwtFilter, WebSocket, CORS
│   │   ├── controller/               # Endpoints REST (v1)
│   │   │   └── master/               # Control Maestro endpoints
│   │   ├── domain/                   # Entidades + DTOs (records)
│   │   │   └── master/               # Entidades y DTOs del Control Maestro
│   │   ├── repository/               # Repositorios JPA
│   │   │   └── master/               # Repos del Control Maestro
│   │   └── services/                 # Lógica de negocio
│   │       └── master/               # Servicios del Control Maestro
│   └── src/main/resources/
│       ├── application-dev.yml       # Config dev (H2, JWT)
│       └── db/migrations/            # V1–V20 Flyway migrations
├── control-master/                   # Angular 21 Admin Panel
│   ├── src/app/
│   │   ├── core/                     # Auth, Interceptor, Guard, API Service
│   │   ├── layout/                   # Sidebar + Toolbar
│   │   └── pages/                    # Login, Dashboard, Clients, Tickets, etc.
│   ├── .postcssrc.json               # Tailwind CSS v4 config
│   └── angular.json                  # Angular config (polyfills: zone.js)
├── docs-v0.2/                        # Documentación del proyecto
│   ├── CONTROL_MAESTRO.md            # Especificaciones del Control Maestro
│   ├── CONTRATOS_API.md              # Contratos API (28 endpoints)
│   ├── FLUJO_COMPLETO_SISTEMA.md     # Flujo completo
│   └── ...
└── Docs/                             # Documentación adicional
```

---

## Módulos Implementados

### Fase I — Backend (25+ endpoints)

| Módulo | Endpoints | Estado |
|--------|-----------|--------|
| Auth (Google + JWT) | verificar, registrar, login | ✅ |
| Negocio CRUD | crear, detalle, editar, listar cajeros | ✅ |
| Enlace | generar invitación, enlazar cajero | ✅ |
| Producto CRUD | listar, crear, editar, eliminar | ✅ |
| Sesión Cajero | abrir, estado, cerrar | ✅ |
| Transacciones | crear, listar, detalle | ✅ |
| Corte Diario | ejecutar, historial | ✅ |
| Cancelaciones | crear, listar | ✅ |
| Notificaciones | listar, marcar leída | ✅ |
| Licencias | verificar, renovar | ✅ |
| Sync / Reportes | sync, reportes | ✅ |
| SuperSu | login, listarAdmins, detalleAdmin, activar/desactivar, estadísticas | ✅ |

### Control Maestro — Backend

| Módulo | Endpoints | Estado |
|--------|-----------|--------|
| Auth | login, me | ✅ |
| Dashboard | stats, charts, activity | ✅ |
| Clients | list, detail, toggle, plan | ✅ |
| Tickets | CRUD, assign, messages | ✅ |
| Operations | force-close, block, adjust-balance | ✅ |
| Team | CRUD, performance | ✅ |
| Billing | summary, invoices, plans | ✅ |
| WebSocket | STOMP over SockJS (/ws/chat) | ✅ |

### Control Maestro — Frontend (Angular 21)

| Componente | Ruta | Estado |
|------------|------|--------|
| Login | `/login` | ✅ |
| Layout (Sidebar + Toolbar) | — | ✅ |
| Dashboard | `/dashboard` | ✅ |
| Clientes | `/clients` | ✅ |
| Detalle Cliente | `/clients/:id` | ✅ |
| Tickets | `/tickets` | ✅ |
| Detalle Ticket | `/tickets/:id` | ✅ |
| Operaciones | `/operations` | ✅ |
| Equipo | `/team` | ✅ |
| Facturación | `/billing` | ✅ |

---

## Credenciales de Desarrollo

### Control Maestro

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `jesus` | `dev123` | DEVELOPER |
| `fanner` | `dev123` | DEVELOPER |
| `leandro` | `dev123` | DATA_SCIENTIST |
| `soporte1` | `sup123` | SOPORTE |
| `soporte2` | `sup123` | SOPORTE |

---

## Cómo Ejecutar

### Backend

```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
# API disponible en http://localhost:8080
# Swagger: http://localhost:8080/swagger-ui/index.html
```

### Control Maestro (Frontend)

```bash
cd control-master
npm install
ng serve --port 4200
# Disponible en http://localhost:4200
```

---

## Base de Datos

Flyway controla todas las migraciones. En dev usa H2 (en memoria).

| Migración | Tabla | Descripción |
|-----------|-------|-------------|
| V1–V13 | Sistema principal | negocios, administradores, cajeros, productos, etc. |
| V14 | master_users | Usuarios staff del Control Maestro |
| V15 | master_tickets | Tickets de soporte |
| V16 | master_messages | Mensajes de chat/tickets |
| V17 | master_incidents | Incidencias del sistema |
| V18 | master_audit_log | Log de auditoría de acciones |
| V19 | master_invoices | Facturas |
| V20 | Seed data | Datos iniciales (5 usuarios, 3 tickets, etc.) |

---

## Documentación

- [Control Maestro — Especificaciones](docs-v0.2/CONTROL_MAESTRO.md)
- [Contratos API v0.2](docs-v0.2/CONTRATOS_API.md) — 28 endpoints documentados
- [Flujo Completo del Sistema](docs-v0.2/FLUJO_COMPLETO_SISTEMA.md)
- [Arquitectura](docs-v0.2/ARQUITECTURA.md)
- [Modelo de Datos](docs-v0.2/MODELO_DATOS.md)

---

## Equipo

| Nombre | Rol | Stack |
|--------|-----|-------|
| Jesús Martínez | Backend + Control Maestro | Java, Spring Boot, Angular |
| Fanner García | App Móvil | Flutter, Dart |
| Leandro Reyes | Data Science | Python, ML |

---

## Licencia

Proyecto privado — Taco'Os © 2026
