# Control Maestro — Taco'Os

> Documento de especificaciones del panel de administración central.
> Equipo: Jesús (Backend), Fanner (Flutter), Leandro (Data Science)

---

## 1. Visión General

El **Control Maestro** es el centro de operaciones para el equipo de Taco'Os. Desde aquí se monitorea, administra y da soporte a todos los clientes (taquerías) que usan la plataforma.

**Decisión clave: Base de datos compartida.** El Control Maestro usa la misma DB que el backend principal (H2 en dev, PostgreSQL en producción). Las nuevas tablas (master_tickets, master_users, etc.) se crean con Flyway en el mismo esquema.

```
┌─────────────────────────────────────────────────────────────┐
│                     CONTROL MAESTRO                         │
│              Angular 21 + Material + Tailwind               │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│ Métricas │ Chat/    │ Clientes │ Reparar/ │ Administración │
│ Clients  │ Soporte  │ CRUD     │ Forzar   │ Financiera     │
├──────────┴──────────┴──────────┴──────────┴────────────────┤
│              Empleados de Mantenimiento                     │
│         (reportan incidencias, reparan problemas)           │
├─────────────────────────────────────────────────────────────┤
│                    Backend API (Java)                        │
│         SuperSu + JWT Auth + Flyway + WebSocket             │
├─────────────────────────────────────────────────────────────┤
│              ╔═══════════════════════════╗                  │
│              ║   MISMA BASE DE DATOS     ║                  │
│              ║   (tacoosdb)              ║                  │
│              ╚═══════════════════════════╝                  │
│ negocios | administradores | cajeros | productos | ...     │
│ master_tickets | master_messages | master_users | ...       │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Stack Tecnológico

### Frontend
| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Angular | 21+ | Framework principal |
| TypeScript | 5.8+ | Tipado estricto |
| **Angular Material** | **21** | **Componentes UI (tabs, tablas, forms, modals, toasts)** |
| **Tailwind CSS** | **4** | **Utilities para layouts, spacing, diseño custom** |
| ApexCharts / ng-apexcharts | 4.7+ | Gráficas y métricas |
| Angular Signals | built-in | State management reactivo |
| RxJS | 7+ | Streams y reactividad |
| ngx-translate | 15+ | Internacionalización (ES/EN) |
| Angular CDK | 21 | Drag & drop, virtual scroll |

> **Decisión UI: Angular Material + Tailwind.** La combinación más usada en Angular admin panels. Material provee componentes listos y accesibles (data tables, dialogs, forms), Tailwind permite diseño custom rápido sin escribir CSS custom extenso.

### Backend (extensión del existente)
| Componente | Descripción |
|-----------|-------------|
| Nuevos endpoints REST | API para métricas, chat, tickets |
| WebSocket (STOMP) | Chat en tiempo real |
| **Misma DB** | **H2 en dev, PostgreSQL en producción. Flyway crea las nuevas tablas en el mismo esquema** |
| Redis (futuro) | Cache de métricas, sesiones |

### Decisiones de Arquitectura
- **Standalone components** (sin NgModules)
- **Signals + RxJS** para estado global
- **Feature-first** structure (carpetas por módulo, no por tipo de archivo)
- **Lazy loading** en todas las rutas
- **RBAC** (Role-Based Access Control) con 3 roles: `super_admin`, `soporte`, `developer`

---

## 3. Módulos del Sistema

### 3.1 Dashboard General (`/dashboard`)

Vista de alto nivel con KPIs del sistema completo.

```
┌──────────────────────────────────────────────────────┐
│  DASHBOARD GENERAL                                   │
├──────────┬──────────┬──────────┬────────────────────┤
│ Clientes │ Sesiones │ Ingresos │ Tickets Abiertos   │
│ Activos  │ Activas  │ Mensual  │                    │
│    45    │    23    │ $12,500  │       8            │
├──────────┴──────────┴──────────┴────────────────────┤
│                                                      │
│  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │ Gráfica de Clientes  │  │ Gráfica de Ingresos │  │
│  │ por Mes (barras)     │  │ por Plan (donut)    │  │
│  └─────────────────────┘  └─────────────────────┘  │
│                                                      │
│  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │ Tickets por Estado   │  │ Top 5 Taquerías     │  │
│  │ (line chart)         │  │ por Ventas          │  │
│  └─────────────────────┘  └─────────────────────┘  │
│                                                      │
│  Última actividad del sistema (timeline)             │
└──────────────────────────────────────────────────────┘
```

**Métricas mostradas:**
- Total clientes activos / inactivos
- Sesiones de cajeros abiertas ahora
- Ingresos mensuales (por planes: FREE, BUSINESS, PREMIUM)
- Tickets de soporte abiertos / resueltos / en progreso
- Gráfica de crecimiento de clientes (6 meses)
- Distribución de clientes por plan (donut)
- Top 5 taquerías con más ventas
- Timeline de actividad reciente

---

### 3.2 Gestión de Clientes (`/clients`)

CRUD completo de todos los clientes (dueños y sus negocios).

```
┌──────────────────────────────────────────────────────┐
│  CLIENTES                                  [+ Nuevo] │
├──────────────────────────────────────────────────────┤
│  🔍 Buscar...    [Todos] [Dueños] [Cajeros] [Inactivos] │
├──────────────────────────────────────────────────────┤
│  ┌─────┬────────────┬───────────────┬────────┬────┐ │
│  │ ID  │ Nombre     │ Negocio       │ Plan   │ ⚙️ │ │
│  ├─────┼────────────┼───────────────┼────────┼────┤ │
│  │ 001 │ Juan Pérez │ Tacos Güero   │ PREMIUM│ 👁️│ │
│  │ 002 │ María López│ La Esquina    │ BUSINESS│ 👁️│ │
│  │ 003 │ Carlos García│ Don Pepe    │ FREE   │ 👁️│ │
│  └─────┴────────────┴───────────────┴────────┴────┘ │
│                                    ← 1 2 3 4 5 →    │
└──────────────────────────────────────────────────────┘
```

**Detalle de Cliente (`/clients/:id`):**
- Info personal (nombre, email, teléfono, idGoogle)
- Info del negocio (nombre, dirección, teléfono, categoría)
- Estado de licencia (plan, vencimiento, estado)
- Cajeros enlazados
- Historial de transacciones (resumen)
- Tickets de soporte asociados
- Botones de acción:
  - Activar / Desactivar cuenta
  - Cambiar plan (FREE → BUSINESS → PREMIUM)
  - Reiniciar contraseña / forzar re-login
  - Ver logs de actividad

---

### 3.3 Chat / Soporte (`/support`)

Sistema de mensajería y tickets de soporte.

```
┌──────────────────────────────────────────────────────┐
│  SOPORTE                                   [+ Ticket] │
├───────────────┬──────────────────────────────────────┤
│               │                                      │
│  Tickets      │  Chat con Juan Pérez                │
│  ┌──────────┐ │  ─────────────────────────────────  │
│  │ 🔴 #1042 │ │  [Cliente] Hola, no me funciona el │
│  │ Juan P.  │ │  corte diario, me sale error.       │
│  │ Urgente  │ │                                      │
│  ├──────────┤ │  [Soporte] ¿Qué mensaje de error    │
│  │ 🟡 #1041 │ │  te aparece? Puedes mandar captura?  │
│  │ María L. │ │                                      │
│  │ Normal   │ │  [Cliente] Dice "Error 500"          │
│  ├──────────┤ │                                      │
│  │ 🟢 #1040 │ │  [Soporte] Ok, ya lo reviso...       │
│  │ Carlos G.│ │  ─────────────────────────────────  │
│  │ Resuelto │ │  📎 Adjuntos  [Escribe mensaje...]  │
│  └──────────┘ │                          [Enviar]    │
│               │                                      │
└───────────────┴──────────────────────────────────────┘
```

**Funcionalidades:**
- **Tickets:** Crear, asignar, priorizar (urgente/alto/normal/bajo), cambiar estado (abierto/en progreso/resuelto/cerrado)
- **Chat en tiempo real:** WebSocket (STOMP over SockJS)
- **Asignación manual:** Asignar ticket a un empleado de mantenimiento
- **Historial completo:** Todas las conversaciones guardadas
- **Adjuntos:** Imágenes, capturas de error, logs
- **Notificaciones:** Push notifications para nuevos tickets
- **SLA tracking:** Tiempo de respuesta promedio, tiempo de resolución

---

### 3.4 Reparación y Control (`/operations`)

Para forzar acciones y reparar problemas manualmente.

```
┌──────────────────────────────────────────────────────┐
│  OPERACIONES                                         │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │ ACCIONES RÁPIDAS                                │ │
│  │                                                  │ │
│  │ [🔄 Reiniciar Sesión]  [🔒 Bloquear Usuario]   │ │
│  │ [💰 Ajustar Saldo]     [📋 Forzar Corte]       │ │
│  │ [🔄 Sincronizar DB]    [📊 Regenerar Reporte]  │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │ INCIDENCIAS RECIENTES                            │ │
│  │                                                  │ │
│  │ #INC-045 | Tacos Güero | Sesión stuck | 🔴 Alta │ │
│  │   → Acción: Forzar cierre de sesión             │ │
│  │   → Resultado: ✅ Resuelto                      │ │
│  │                                                  │ │
│  │ #INC-044 | La Esquina | Datos corruptos | 🟡 Med│ │
│  │   → Acción: Rollback a backup del 15/06         │ │
│  │   → Resultado: ⏳ En progreso                   │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**Acciones disponibles:**
- **Forzar cierre de sesión** de cajero
- **Bloquear/desbloquear** usuario
- **Ajustar saldo** (dineroBase) de un negocio
- **Forzar corte diario** manual
- **Sincronizar datos** pendientes
- **Regenerar reportes** con datos recalculados
- **Rollback** a punto de backup
- **Ejecutar query SQL** directa (solo devs, con confirmación)
- **Ver logs** de errores del sistema en tiempo real

---

### 3.5 Administración Financiera (`/billing`)

Control económico de todos los clientes.

```
┌──────────────────────────────────────────────────────┐
│  FACTURACIÓN                                         │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Resumen Mensual:                                    │
│  ┌──────────┬──────────┬──────────┬───────────────┐ │
│  │ Ingresos │ Pagados  │ Pendiente│ MRR           │ │
│  │ $12,500  │ $10,200  │ $2,300   │ $12,500       │ │
│  └──────────┴──────────┴──────────┴───────────────┘ │
│                                                      │
│  Clientes por Plan:                                  │
│  ┌──────────────────────────────────────────────┐   │
│  │ ████████████████████████  PREMIUM  ($99)  15 │   │
│  │ ██████████████████        BUSINESS ($49)  20 │   │
│  │ ████████                  FREE     ($0)   10 │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  Facturas:                                           │
│  ┌────────┬────────────┬────────┬──────────┬─────┐ │
│  │ #INV001│ Juan Pérez │ $99.00 │ 15/06/26 │ ✅  │ │
│  │ #INV002│ María López│ $49.00 │ 15/06/26 │ ⏳  │ │
│  │ #INV003│ Carlos García│ $0.00│ 01/06/26 │ ✅  │ │
│  └────────┴────────────┴────────┴──────────┴─────┘ │
└──────────────────────────────────────────────────────┘
```

**Funcionalidades:**
- Ingresos totales y por mes (MRR - Monthly Recurring Revenue)
- Clientes por plan (donut chart)
- Historial de facturas
- Generar factura manual
- Cambiar plan de un cliente (con prorrateo)
- Descuentos y cupones
- Reportes de ingresos exportables (CSV/Excel)

---

### 3.6 Empleados de Mantenimiento (`/team`)

Gestión del equipo interno de soporte.

```
┌──────────────────────────────────────────────────────┐
│  EQUIPO                                    [+ Miembro]│
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────┬──────────────┬────────────┬──────────────┐ │
│  │ Avatar│ Nombre     │ Rol        │ Tickets Hoy  │ │
│  ├─────┼──────────────┼────────────┼──────────────┤ │
│  │ 👤  │ Jesús M.    │ Developer  │ 3 (1 urgente)│ │
│  │ 👤  │ Fanner G.   │ Developer  │ 0            │ │
│  │ 👤  │ Leandro R.  │ Data Sci.  │ 1            │ │
│  │ 👤  │ Ana López   │ Soporte    │ 5 (2 urgentes│ │
│  └─────┴──────────────┴────────────┴──────────────┘ │
│                                                      │
│  Rendimiento del Equipo:                             │
│  ┌──────────────────────────────────────────────┐   │
│  │ Tiempo promedio de respuesta: 2.3 horas      │   │
│  │ Tickets resueltos esta semana: 34            │   │
│  │ Tasa de resolución en primer contacto: 78%   │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

**Roles del equipo:**
- **developer:** Acceso total, puede ejecutar queries SQL, forzar acciones
- **soporte:** Atención a clientes, resolver tickets, chat
- **data_scientist:** Solo lectura de métricas, reportes, analytics

**Funcionalidades:**
- Asignar tickets a miembros del equipo
- Ver carga de trabajo por empleado
- Métricas de rendimiento individual
- Historial de acciones por empleado (audit log)
- Invitar nuevos miembros
- Desactivar cuentas de empleados

---

## 4. Arquitectura de Rutas

```
/control-master/
├── /login                    → Login (JWT propio)
├── /dashboard                → Dashboard general
├── /clients                  → Lista de clientes
│   └── /:id                  → Detalle de cliente
├── /support                  → Tickets + Chat
│   └── /:ticketId            → Conversación del ticket
├── /operations               → Reparación y control
├── /billing                  → Facturación
├── /team                     → Equipo de mantenimiento
│   └── /:memberId            → Perfil del miembro
├── /settings                 → Configuración del sistema
│   ├── /general              → Nombre, logo, configs
│   ├── /notifications        → Templates de notificaciones
│   └── /security             → IPs permitidas, 2FA
└── /logs                     → Audit log del sistema
```

---

## 5. Endpoints API Necesarios (Nuevos)

### Dashboard
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/dashboard/stats` | GET | KPIs generales |
| `/api/v1/master/dashboard/charts` | GET | Datos para gráficas |
| `/api/v1/master/dashboard/activity` | GET | Timeline de actividad |

### Clients
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/clients` | GET | Listar todos los clientes |
| `/api/v1/master/clients/:id` | GET | Detalle de cliente |
| `/api/v1/master/clients/:id` | PUT | Actualizar cliente |
| `/api/v1/master/clients/:id/toggle` | PUT | Activar/Desactivar |
| `/api/v1/master/clients/:id/plan` | PUT | Cambiar plan |
| `/api/v1/master/clients/:id/sessions` | GET | Sesiones del cliente |
| `/api/v1/master/clients/:id/transactions` | GET | Transacciones del cliente |
| `/api/v1/master/clients/:id/logs` | GET | Logs de actividad |

### Support
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/tickets` | GET | Listar tickets |
| `/api/v1/master/tickets` | POST | Crear ticket |
| `/api/v1/master/tickets/:id` | GET | Detalle del ticket |
| `/api/v1/master/tickets/:id` | PUT | Actualizar ticket |
| `/api/v1/master/tickets/:id/assign` | PUT | Asignar a miembro |
| `/api/v1/master/tickets/:id/messages` | GET | Mensajes del ticket |
| `/api/v1/master/tickets/:id/messages` | POST | Enviar mensaje |
| `/ws/chat` | WebSocket | Chat en tiempo real |

### Operations
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/ops/force-close-session` | POST | Forzar cierre de sesión |
| `/api/v1/master/ops/block-user` | PUT | Bloquear usuario |
| `/api/v1/master/ops/adjust-balance` | PUT | Ajustar saldo |
| `/api/v1/master/ops/force-daily-cut` | POST | Forzar corte diario |
| `/api/v1/master/ops/sync-data` | POST | Forzar sincronización |
| `/api/v1/master/ops/execute-query` | POST | Ejecutar SQL (solo devs) |
| `/api/v1/master/incidents` | GET | Lista de incidencias |
| `/api/v1/master/incidents` | POST | Registrar incidencia |

### Billing
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/billing/summary` | GET | Resumen financiero |
| `/api/v1/master/billing/invoices` | GET | Lista de facturas |
| `/api/v1/master/billing/invoices` | POST | Generar factura |
| `/api/v1/master/billing/plans` | GET | Planes disponibles |

### Team
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/team` | GET | Listar miembros |
| `/api/v1/master/team` | POST | Invitar miembro |
| `/api/v1/master/team/:id` | GET | Perfil del miembro |
| `/api/v1/master/team/:id/performance` | GET | Métricas de rendimiento |
| `/api/v1/master/team/:id` | PUT | Actualizar miembro |
| `/api/v1/master/team/:id` | DELETE | Desactivar miembro |

### Auth (nuevo login separado)
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/master/auth/login` | POST | Login del control maestro |
| `/api/v1/master/auth/me` | GET | Info del usuario logueado |

---

## 6. Modelo de Datos (Nuevas Tablas)

```sql
-- Tickets de soporte
CREATE TABLE master_tickets (
    id              UUID PRIMARY KEY,
    client_id       UUID NOT NULL,          -- REFERENCES administradores(id)
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    priority        VARCHAR(20) NOT NULL DEFAULT 'NORMAL',  -- URGENTE, ALTO, NORMAL, BAJO
    status          VARCHAR(20) NOT NULL DEFAULT 'ABIERTO', -- ABIERTO, EN_PROGRESO, RESUELTO, CERRADO
    assigned_to     UUID,                   -- REFERENCES master_users(id)
    created_by      UUID NOT NULL,          -- REFERENCES master_users(id)
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     TIMESTAMP
);

-- Mensajes de chat/tickets
CREATE TABLE master_messages (
    id              UUID PRIMARY KEY,
    ticket_id       UUID NOT NULL,          -- REFERENCES master_tickets(id)
    sender_id       UUID NOT NULL,          -- master_users o administradores
    sender_type     VARCHAR(20) NOT NULL,   -- 'STAFF' o 'CLIENT'
    content         TEXT NOT NULL,
    attachment_url  VARCHAR(500),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Usuarios del control maestro (staff interno)
CREATE TABLE master_users (
    id              UUID PRIMARY KEY,
    username        VARCHAR(100) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    role            VARCHAR(30) NOT NULL,   -- DEVELOPER, SOPORTE, DATA_SCIENTIST
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Incidencias (problemas detectados o reportados)
CREATE TABLE master_incidents (
    id              UUID PRIMARY KEY,
    client_id       UUID,                   -- REFERENCES administradores(id), nullable si es del sistema
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    severity        VARCHAR(20) NOT NULL,   -- CRITICA, ALTA, MEDIA, BAJA
    status          VARCHAR(20) NOT NULL,   -- DETECTADA, EN_INVESTIGACION, EN_REPARACION, RESUELTA
    detected_by     UUID,                   -- master_users(id) o 'SYSTEM'
    assigned_to     UUID,                   -- master_users(id)
    action_taken    TEXT,                   -- Qué se hizo para reparar
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     TIMESTAMP
);

-- Audit log (acciones de staff)
CREATE TABLE master_audit_log (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL,          -- master_users(id)
    action          VARCHAR(100) NOT NULL,  -- 'BLOCK_USER', 'FORCE_CLOSE_SESSION', etc.
    target_type     VARCHAR(50),            -- 'CLIENT', 'TICKET', 'INCIDENT', etc.
    target_id       UUID,
    details         JSONB,                  -- Detalles de la acción
    ip_address      VARCHAR(45),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Facturas
CREATE TABLE master_invoices (
    id              UUID PRIMARY KEY,
    client_id       UUID NOT NULL,          -- REFERENCES administradores(id)
    amount          DECIMAL(10,2) NOT NULL,
    plan            VARCHAR(50) NOT NULL,
    status          VARCHAR(20) NOT NULL,   -- PENDIENTE, PAGADA, VENCIDA
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 7. Decisiones Técnicas

### Base de Datos Compartida
- El Control Maestro usa la **misma base de datos** que el backend principal
- En dev: `jdbc:h2:mem:tacoosdb`
- En producción: PostgreSQL (misma instancia)
- Las nuevas tablas (`master_*`) se crean con Flyway como V14, V15, etc.
- Puede hacer JOINs entre tablas del sistema principal y del control maestro
- Ejemplo: `master_tickets.client_id` → `administradores.id`

### Autenticación del Control Maestro
- **Separada** del login de clientes (no usa el mismo JWT de SuperSu)
- Login propio en `/api/v1/master/auth/login`
- JWT con claims: `sub`, `username`, `role`, `permissions`
- Tokens de corta duración (1 hora) con refresh

### State Management
- **Signals** para estado global (tema, usuario logueado, notificaciones)
- **RxJS** para WebSocket y datos del servidor
- **Feature stores** por módulo (clients store, tickets store, etc.)

### Componentes Base
- **Standalone components** en todo momento
- **Lazy loading** por módulo
- **OnPush change detection** para performance
- **Shared module** con componentes reutilizables (tablas, formularios, cards)

### UI/UX
- **Angular Material** para componentes: MatTable, MatDialog, MatTabs, MatSidenav, MatToolbar, MatCard, MatButton, MatInput, MatSelect, MatToast
- **Tailwind CSS** para: layouts, spacing, colores custom, responsive breakpoints, dark mode
- **Dark/Light mode** (toggle en header, persiste en localStorage)
- **Sidebar colapsable** con iconos (MatSidenav)
- **Responsive** (funciona en tablet para soporte móvil)
- **Snack bars** (Material) para notificaciones inline
- **Confirmación** (MatDialog) para acciones destructivas
- **Skeleton loaders** (MatProgressBar) mientras carga datos

---

## 8. Flujo de Trabajo Típico

```
1. Cliente reporta problema (desde app Flutter)
   → Se crea ticket automáticamente o manualmente
   
2. Soporte recibe notificación (nuevo ticket)
   → Ve el ticket en la cola de soporte
   → Responde por chat: "¿Qué error te aparece?"
   
3. Cliente responde con captura
   → Soporte analiza, intenta reproducir
   
4. Si es problema conocido → Resuelve
   → Forza acción desde Operations (ej: reiniciar sesión)
   → Marca ticket como resuelto
   
5. Si es bug nuevo → Asigna a developer
   → Developer investiga (puede ejecutar SQL)
   → Registra incidencia
   → Repara el código
   → Cierra incidencia y ticket
   
6. Métricas se actualizan automáticamente
   → Dashboard refleja nuevos números
```

---

## 9. Plantillas de UI (Referencia)

Basado en investigación, las mejores opciones para Angular 21:

| Plantilla | License | Estilo | Match con nuestro caso |
|-----------|---------|--------|----------------------|
| **ngx-admin** (Akveo) | MIT | Bootstrap + Nebular | ⭐⭐⭐ El más popular (25K stars), 40+ componentes |
| **TailAdmin Angular** | Free | Tailwind CSS v4 | ⭐⭐⭐ Moderno, Angular 21, gratis |
| **angular-enterprise-ui** | Free | SCSS + Material | ⭐⭐⭐ RBAC, standalone, Signals, enterprise-grade |
| **Circle** | Free | Material + Tailwind | ⭐⭐ i18n, lazy routes, Angular 21 |
| **Admindek** | $69 | Tailwind + Spartan | ⭐⭐ 80+ pages, 9 dashboards, premium |

**Recomendación:** Usar **TailAdmin Angular** (gratis, moderno, Angular 21, Tailwind) o **angular-enterprise-ui** (gratis, enterprise-grade, RBAC built-in) como base, y personalizar con nuestros módulos.

---

## 10. Estado de Implementación

### ✅ Completado

| # | Tarea | Detalle |
|---|-------|---------|
| 1 | Crear proyecto Angular 21 | `control-master/` con Angular 21, standalone components |
| 2 | Integrar Angular Material + Tailwind CSS v4 | Material via `ng add`, Tailwind via `.postcssrc.json` + `@use 'tailwindcss'` |
| 3 | Módulo de Auth | Login JWT propio, interceptor, guard, auth.service.ts |
| 4 | Endpoints backend (7 controllers) | MasterAuth, MasterDashboard, MasterClient, MasterTicket, MasterOperations, MasterTeam, MasterBilling |
| 5 | Flyway migrations V14–V20 | master_users, master_tickets, master_messages, master_incidents, master_audit_log, master_invoices + seed data |
| 6 | Dashboard | KPIs, stats, charts, activity |
| 7 | CRUD de clientes | Lista, detalle, toggle activar/desactivar, cambiar plan |
| 8 | Sistema de tickets | CRUD, asignación, mensajes/chat, prioridades |
| 9 | Módulo de operaciones | Forzar cierre sesión, bloquear usuario, ajustar saldo |
| 10 | Gestión de equipo | CRUD miembros, rendimiento, métricas |
| 11 | Módulo de facturación | Resumen, facturas, planes |
| 12 | WebSocket | STOMP over SockJS en `/ws/chat` |
| 13 | JWT filter actualizado | Master roles (`master_*`) → `ROLE_MASTER` |
| 14 | CORS habilitado | `localhost:4200` y `localhost:4201` |
| 15 | Layout (Sidebar + Toolbar) | Navegación lateral colapsable |
| 16 | Zone.js configurado | Angular 21 zoneless mode + polyfill |

### ⏳ Pendiente

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Conectar WebSocket para chat en tiempo real | Alta |
| 2 | Gráficas reales con ng-apexcharts | Media |
| 3 | Dark/Light mode toggle | Media |
| 4 | Skeleton loaders | Baja |
| 5 | Testing (Vitest + Cypress para E2E) | Media |
| 6 | Audit logging frontend | Baja |
| 7 | Notificaciones push | Baja |
