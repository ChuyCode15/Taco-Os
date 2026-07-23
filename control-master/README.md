# Control Maestro — Taco'Os

Panel de administración central para el equipo de Taco'Os. Monitorea, administra y da soporte a todos los clientes (taquerías) que usan la plataforma.

---

## Stack

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Angular | 21+ | Framework principal |
| Angular Material | 21 | Componentes UI (tablas, forms, dialogs, tabs) |
| Tailwind CSS | 4 | Utilities para layouts y diseño custom |
| TypeScript | 5.9+ | Tipado estricto |
| RxJS | 7+ | Streams y reactividad |
| Angular Signals | built-in | State management reactivo |

---

## Estructura

```
control-master/src/app/
├── core/
│   ├── auth.service.ts          # Login/logout/token
│   ├── auth.interceptor.ts      # JWT interceptor
│   ├── auth.guard.ts            # Protected routes
│   └── api.service.ts           # Todas las llamadas REST
├── layout/
│   └── layout.component.ts      # Sidebar + Toolbar
└── pages/
    ├── login/                   # Login screen
    ├── dashboard/               # KPIs y métricas
    ├── clients/                 # Lista de clientes
    ├── client-detail/           # Detalle de cliente
    ├── tickets/                 # Tickets de soporte
    ├── ticket-detail/           # Chat del ticket
    ├── operations/              # Forzar acciones
    ├── team/                    # Equipo interno
    └── billing/                 # Facturación
```

---

## Cómo Ejecutar

```bash
# Instalar dependencias
npm install

# Desarrollo
ng serve --port 4200

# Build producción
ng build --configuration production
```

---

## Credenciales (Dev)

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `jesus` | `dev123` | DEVELOPER |
| `fanner` | `dev123` | DEVELOPER |
| `leandro` | `dev123` | DATA_SCIENTIST |
| `soporte1` | `sup123` | SOPORTE |
| `soporte2` | `sup123` | SOPORTE |

---

## Backend Requerido

El frontend consume la API del backend Spring Boot en `http://localhost:8080`.

```bash
# Ejecutar backend primero
cd ../backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## Rutas

| Ruta | Componente | Descripción |
|------|-----------|-------------|
| `/login` | LoginComponent | Login JWT |
| `/dashboard` | DashboardComponent | KPIs y métricas |
| `/clients` | ClientsComponent | Lista de clientes |
| `/clients/:id` | ClientDetailComponent | Detalle de cliente |
| `/tickets` | TicketsComponent | Tickets de soporte |
| `/tickets/:id` | TicketDetailComponent | Chat del ticket |
| `/operations` | OperationsComponent | Forzar acciones |
| `/team` | TeamComponent | Equipo interno |
| `/billing` | BillingComponent | Facturación |

---

## API Endpoints Consumidos

Todos bajo `/api/v1/master/`:

| Módulo | Endpoints |
|--------|-----------|
| Auth | `POST /auth/login`, `GET /auth/me` |
| Dashboard | `GET /dashboard/stats`, `GET /dashboard/charts`, `GET /dashboard/activity` |
| Clients | `GET /clients`, `GET /clients/:id`, `PUT /clients/:id/toggle` |
| Tickets | `GET /tickets`, `POST /tickets`, `GET /tickets/:id/messages`, `POST /tickets/:id/messages` |
| Operations | `POST /ops/force-close-session`, `PUT /ops/block-user`, `PUT /ops/adjust-balance` |
| Team | `GET /team`, `POST /team`, `PUT /team/:id` |
| Billing | `GET /billing/summary`, `GET /billing/invoices`, `GET /billing/plans` |
