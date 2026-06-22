# Contratos API — Taco'Os v0.2 (Fase I)

> Documento de contratos y flujo del sistema.
> Orientado a que Fanner (Flutter) y Jesús (Backend) trabajen sincronizados.
> **Cada JSON coincide exactamente con lo que produce el backend (via @JsonProperty).**

---

## Índice

### Backend Principal (28 endpoints)

| Sección | Contenido |
|---------|-----------|
| **B-1** | Auth — Verificar Google ID |
| **B-2** | Auth — Registrar (Dueño o Cajero) |
| **C-1** | Negocio — Crear |
| **C-2** | Negocio — Detalle |
| **C-3** | Negocio — Editar |
| **C-4** | Negocio — Listar Cajeros |
| **D-1** | Enlace — Generar Invitación (Dueño) |
| **D-2** | Enlace — Enlazar Cajero (Cajero) |
| **E** | Producto CRUD |
| **F** | Sesión Cajero |
| **G** | Transacciones |
| **H** | Corte Diario |
| **I** | Cancelaciones |
| **J** | Notificaciones |
| **K** | Licencias |
| **L** | Sync / Reportes |
| **SS** | SuperSu (Super Admin) |

### Control Maestro (20 endpoints)

| Sección | Contenido |
|---------|-----------|
| **M-1** | Auth — Login Control Maestro |
| **M-2** | Dashboard — Stats, Charts, Activity |
| **M-3** | Clients — List, Detail, Toggle, Plan |
| **M-4** | Tickets — CRUD, Assign, Messages |
| **M-5** | Operations — Force Close, Block, Adjust Balance |
| **M-6** | Team — CRUD, Performance |
| **M-7** | Billing — Summary, Invoices, Plans |

---

## Autenticación JWT

Todos los endpoints (excepto auth y SuperSu login) requieren header `Authorization`:

```
Authorization: Bearer <jwt_token>
```

El token JWT se genera al verificar o registrar. Claims: `sub` (UUID usuario), `idGoogle`, `rol`, `nickname`.

---

## B — AUTENTICACIÓN (Entrada al Sistema)

---

### B-1 `GET /api/v1/auth/verificar/{idGoogle}`

**Propósito:** La app consulta si el usuario ya existe en el sistema después del login de Google.

**Response 200 — Usuario existe (Dueño):**
```json
{
  "existe": true,
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "idGoogle": "1234567890",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "rol": "dueño",
    "tieneNegocio": true,
    "negocioId": "550e8400-e29b-41d4-a716-446655440010",
    "negocioNombre": "Taquería Bonita"
  }
}
```

**Response 200 — Usuario existe (Cajero):**
```json
{
  "existe": true,
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440002",
    "idGoogle": "0987654321",
    "nickname": "PedroP",
    "correo": "pedro@email.com",
    "rol": "cajero",
    "tieneNegocio": true,
    "negocioId": "550e8400-e29b-41d4-a716-446655440010",
    "negocioNombre": "Taquería Bonita"
  }
}
```

| Campo | Descripción |
|-------|-------------|
| `token` | JWT firmado con HMAC256. Expira en 12 horas. |
| `vencimiento` | Horas de vigencia del token |
| `rol` | `dueño` / `cajero` |
| `tieneNegocio` | `false` si el dueño aún no registra negocio |
| `negocioNombre` | `null` si no tiene negocio |

**Flutter decide:**
- `rol` = dueño + `tieneNegocio` = true → Dashboard Patrón
- `rol` = dueño + `tieneNegocio` = false → Vista "Registrar tu negocio"
- `rol` = cajero + `tieneNegocio` = true → Pantalla de cobro
- `rol` = cajero + `tieneNegocio` = false → Error (cajero debería tener negocio)

**Response 404 — Usuario nuevo (no existe):**
```json
{
  "existe": false,
  "codigo": "NO_REGISTRADO",
  "mensaje": "Usuario no encontrado. Debe registrarse."
}
```

**Flutter decide:**
Muestra pantalla: *"¿Eres Dueño de negocio o Cajero?"*

---

### B-2 `POST /api/v1/auth/registrar`

**Propósito:** Registrar un usuario nuevo después de que eligió su rol.
**Endpoint único:** El campo `rol` decide si se crea un dueño (administrador) o cajero.

**Request:**
```json
{
  "idGoogle": "1234567890",
  "nickname": "JuanRa",
  "correo": "juan@email.com",
  "numero": "+525512345678",
  "rol": "dueño"
}
```

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `idGoogle` | Sí | ID único de Google |
| `nickname` | Sí | Cómo quiere que le digan |
| `correo` | Sí | Correo de Google |
| `numero` | No | Teléfono del usuario |
| `rol` | Sí | `dueño` / `cajero` |

**Response 201 — Registro exitoso:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "idGoogle": "1234567890",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "rol": "dueño",
    "tieneNegocio": false,
    "negocioId": null,
    "negocioNombre": null
  }
}
```

**Response 409 — Ya registrado:**
```json
{
  "codigo": "YA_EXISTE",
  "mensaje": "El usuario con idGoogle 1234567890 ya está registrado",
  "ubicacion": "AuthService.registrar",
  "status": 409
}
```

---

## C — NEGOCIOS (Dueño)

---

### C-1 `POST /api/v1/business`

**Propósito:** El dueño registra su negocio por primera vez.

**Request:**
```json
{
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00"
}
```

**Response 201:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00",
  "creadoEl": "2026-06-15T10:05:00"
}
```

---

### C-2 `GET /api/v1/business/{id}`

**Propósito:** Obtener detalle del negocio.

**Response 200:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00",
  "creadoEl": "2026-06-15T10:05:00"
}
```

---

### C-3 `PUT /api/v1/business/{id}`

**Propósito:** Editar datos del negocio.

**Request:** Mismos campos que C-1 (todos opcionales).

**Response 200:** Mismo formato que C-2 con valores actualizados.

---

### C-4 `GET /api/v1/business/{id}/cajeros`

**Propósito:** Dueño consulta la lista de cajeros enlazados a su negocio.

**Response 200:**
```json
{
  "cajeros": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "nickname": "PedroP",
      "correo": "pedro@email.com",
      "numero": "+525598765432",
      "tieneSesionAbierta": false,
      "enlazadoEl": "2026-06-15T10:10:00"
    }
  ]
}
```

---

## D — ENLACE CAJERO (QR Handshake)

---

### D-1 `POST /api/v1/business/invitation`

**Propósito:** El dueño genera un código de invitación para que un cajero se enlace.

**Request:**
```json
{
  "negocioId": "550e8400-e29b-41d4-a716-446655440010",
  "duenoId": "550e8400-e29b-41d4-a716-446655440001"
}
```

**Response 201:**
```json
{
  "codigo": "INV-a1b2c3d4",
  "expiraEn": 15,
  "qrPayload": "tacoos://link?codigo=INV-a1b2c3d4"
}
```

---

### D-2 `POST /api/v1/business/link`

**Propósito:** El cajero se enlaza al negocio usando el código de invitación.

**Request:**
```json
{
  "codigo": "INV-a1b2c3d4",
  "usuarioId": "550e8400-e29b-41d4-a716-446655440002"
}
```

**Response 200:**
```json
{
  "enlazado": true,
  "negocioId": "550e8400-e29b-41d4-a716-446655440010",
  "negocioNombre": "Taquería Bonita",
  "negocioDireccion": "Av. Principal 123",
  "moneda": "MXN",
  "dineroBase": 500.00
}
```

---

## E — PRODUCTOS (Dueño)

Auth requerido. Dueño administra productos de su negocio.

### E-1 `POST /api/v1/business/{id}/products`

**Request:**
```json
{
  "nombre": "Taco de asada",
  "precio": 15.00,
  "descripcion": "Taco de carne asada con cilantro y cebolla",
  "categoria": "Tacos"
}
```

**Response 201:**
```json
{
  "id": "550e8400-...",
  "nombre": "Taco de asada",
  "precio": 15.00,
  "descripcion": "Taco de carne asada con cilantro y cebolla",
  "categoria": "Tacos",
  "creadoEl": "2026-06-15T10:05:00"
}
```

### E-2 `GET /api/v1/business/{id}/products`

**Response 200:**
```json
[
  {
    "id": "550e8400-...",
    "nombre": "Taco de asada",
    "precio": 15.00,
    "descripcion": "Taco de carne asada",
    "categoria": "Tacos"
  }
]
```

### E-3 `PUT /api/v1/business/{id}/products/{productId}`

Mismo formato de request/response que E-1.

### E-4 `DELETE /api/v1/business/{id}/products/{productId}`

**Response 200:**
```json
{
  "mensaje": "Producto eliminado exitosamente"
}
```

---

## F — SESIÓN CAJERO

Auth requerido. Cajero abre/cierra sesión de trabajo.

### F-1 `POST /api/v1/cashier/open-session`

**Request:**
```json
{
  "negocioId": "550e8400-...",
  "cajeroId": "550e8400-...",
  "dispositivoId": "device-001",
  "dineroBase": 500.00
}
```

**Response 201:**
```json
{
  "id": "550e8400-...",
  "sessionId": "abc123...",
  "estado": "ABIERTA",
  "fechaApertura": "2026-06-15",
  "dineroBase": 500.00
}
```

### F-2 `POST /api/v1/cashier/close-session`

**Request:**
```json
{
  "sesionId": "550e8400-...",
  "cajeroId": "550e8400-...",
  "dineroFinal": 1250.00
}
```

**Response 200:**
```json
{
  "mensaje": "Sesión cerrada exitosamente"
}
```

---

## G — TRANSACCIONES

Auth requerido. Registra ventas durante la sesión.

### G-1 `POST /api/v1/transactions`

**Request:**
```json
{
  "sesionId": "550e8400-...",
  "cajeroId": "550e8400-...",
  "negocioId": "550e8400-...",
  "total": 50.00,
  "pago": {
    "metodo": "EFECTIVO",
    "montoRecibido": 50.00,
    "cambio": 0.00,
    "notas": null
  }
}
```

**Response 201:**
```json
{
  "id": "550e8400-...",
  "estado": "COMPLETADA",
  "fechaTransaccion": "2026-06-15T10:30:00"
}
```

---

## H — CORTE DIARIO

Auth requerido. Cajero cierra caja al final del día.

### H-1 `POST /api/v1/cashier/daily-cut`

**Request:**
```json
{
  "sesionId": "550e8400-...",
  "cajeroId": "550e8400-...",
  "dineroEsperado": 1500.00,
  "dineroReal": 1480.00,
  "observaciones": "Faltante de $20"
}
```

**Response 201:**
```json
{
  "id": "550e8400-...",
  "fecha": "2026-06-15",
  "totalVentas": 1000.00,
  "totalTransacciones": 15,
  "dineroBase": 500.00,
  "dineroEsperado": 1500.00,
  "dineroReal": 1480.00,
  "diferencia": -20.00,
  "observaciones": "Faltante de $20"
}
```

---

## I — CANCELACIONES

Auth requerido. Cancela una transacción.

### I-1 `POST /api/v1/transactions/{id}/cancel`

**Request:**
```json
{
  "motivo": "Cliente se arrepintió",
  "canceladoPor": "550e8400-..."
}
```

**Response 200:**
```json
{
  "mensaje": "Transacción cancelada exitosamente"
}
```

---

## J — NOTIFICACIONES

Auth requerido. Sistema de notificaciones internas.

### J-1 `GET /api/v1/notifications/{userId}`

**Response 200:**
```json
[
  {
    "id": "550e8400-...",
    "titulo": "Bienvenido",
    "mensaje": "Tu cuenta ha sido creada",
    "tipo": "INFO",
    "leido": false,
    "fechaCreacion": "2026-06-15T10:00:00"
  }
]
```

### J-2 `PUT /api/v1/notifications/{id}/read`

**Response 200:**
```json
{
  "mensaje": "Notificación marcada como leída"
}
```

---

## K — LICENCIAS

Auth requerido. Licencia de uso del sistema.

### K-1 `GET /api/v1/licenses/{negocioId}`

**Response 200:**
```json
{
  "id": "550e8400-...",
  "negocioId": "550e8400-...",
  "tipo": "GRATUITA",
  "fechaInicio": "2026-06-15",
  "fechaVencimiento": "2026-07-15",
  "activa": true
}
```

---

## L — SYNC / REPORTES

Auth requerido.

### L-1 `POST /api/v1/sync`

**Request:**
```json
{
  "cajeroId": "550e8400-...",
  "sesionId": "550e8400-...",
  "transacciones": []
}
```

**Response 200:**
```json
{
  "sincronizadas": 0,
  "fallidas": 0,
  "mensaje": "Sincronización completada"
}
```

### L-2 `GET /api/v1/reports/{negocioId}`

**Response 200:**
```json
{
  "negocioId": "550e8400-...",
  "totalVentas": 5000.00,
  "totalTransacciones": 75,
  "ticketPromedio": 66.67
}
```

---

## SS — SUPERSU (Super Admin)

> Acceso exclusivo para administradores del sistema.
> Credenciales dev: User `SuperSu`, Pass `AdminSu`

### SS-1 `POST /api/v1/super-su/login`

**Request:**
```json
{
  "usuario": "SuperSu",
  "contrasena": "AdminSu"
}
```

**Response 200:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-...",
    "usuario": "SuperSu",
    "rol": "super_admin"
  }
}
```

**Response 401:**
```json
{
  "codigo": "CREDENCIALES_INVALIDAS",
  "mensaje": "Usuario o contraseña incorrectos",
  "status": 401
}
```

### SS-2 `GET /api/v1/super-su/admins`

Auth requerido (ROLE_SUPER_ADMIN).

**Response 200:**
```json
[
  {
    "id": "550e8400-...",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "numero": "+525512345678",
    "negocioNombre": "Taquería Bonita",
    "activo": true,
    "creadoEl": "2026-06-15T10:00:00"
  }
]
```

### SS-3 `GET /api/v1/super-su/admins/{id}`

**Response 200:** Detalle del administrador con información del negocio.

### SS-4 `PUT /api/v1/super-su/admins/{id}/activate`

**Response 200:**
```json
{
  "mensaje": "Administrador activado exitosamente"
}
```

### SS-5 `PUT /api/v1/super-su/admins/{id}/deactivate`

**Response 200:**
```json
{
  "mensaje": "Administrador desactivado exitosamente"
}
```

### SS-6 `GET /api/v1/super-su/stats`

**Response 200:**
```json
{
  "totalAdministradores": 5,
  "totalNegocios": 5,
  "totalCajeros": 10,
  "administradoresActivos": 4,
  "administradoresInactivos": 1
}
```

---

## Resumen de Endpoints (Fase I — Todos Implementados)

| Sec | Endpoint | Método | Controller |
|-----|----------|--------|-----------|
| B-1 | `/api/v1/auth/verificar/{idGoogle}` | GET | AuthController |
| B-2 | `/api/v1/auth/registrar` | POST | AuthController |
| C-1 | `/api/v1/business` | POST | negociosController |
| C-2 | `/api/v1/business/{id}` | GET | negociosController |
| C-3 | `/api/v1/business/{id}` | PUT | negociosController |
| C-4 | `/api/v1/business/{id}/cajeros` | GET | negociosController |
| D-1 | `/api/v1/business/invitation` | POST | EnlaceController |
| D-2 | `/api/v1/business/link` | POST | EnlaceController |
| E-1 | `/api/v1/business/{id}/products` | POST | ProductoController |
| E-2 | `/api/v1/business/{id}/products` | GET | ProductoController |
| E-3 | `/api/v1/business/{id}/products/{productId}` | PUT | ProductoController |
| E-4 | `/api/v1/business/{id}/products/{productId}` | DELETE | ProductoController |
| F-1 | `/api/v1/cashier/open-session` | POST | CashierSessionController |
| F-2 | `/api/v1/cashier/close-session` | POST | CashierSessionController |
| G-1 | `/api/v1/transactions` | POST | TransaccionController |
| H-1 | `/api/v1/cashier/close-session` | POST | DailyCutController |
| I-1 | `/api/v1/transactions/{id}/cancel` | POST | TransaccionController |
| J-1 | `/api/v1/business/{negocioId}/notifications` | GET | NotificacionController |
| J-2 | `/api/v1/business/{negocioId}/notifications/{id}` | DELETE | NotificacionController |
| K-1 | `/api/v1/business/{negocioId}/license` | GET | LicenciaController |
| K-2 | `/api/v1/plans` | GET | LicenciaController |
| K-3 | `/api/v1/business/{negocioId}/license/upgrade` | POST | LicenciaController |
| K-4 | `/api/v1/business/{negocioId}/license/trial` | POST | LicenciaController |
| L-1 | `/api/v1/sync` | POST | SyncController |
| L-2 | `/api/v1/business/{negocioId}/reports/open-sessions` | GET | ReporteController |
| L-3 | `/api/v1/business/{negocioId}/reports/cuts` | GET | ReporteController |
| L-4 | `/api/v1/business/{negocioId}/reports/stats` | GET | ReporteController |
| SS-1 | `/api/v1/super-su/login` | POST | SuperSuController |
| SS-2 | `/api/v1/super-su/admins` | GET | SuperSuController |
| SS-3 | `/api/v1/super-su/admins/{id}` | GET | SuperSuController |
| SS-4 | `/api/v1/super-su/admins/{id}/activar` | PUT | SuperSuController |
| SS-5 | `/api/v1/super-su/admins/{id}/desactivar` | PUT | SuperSuController |
| SS-6 | `/api/v1/super-su/stats` | GET | SuperSuController |

---

## CONTROL MAESTRO — Endpoints

> Todos los endpoints requieren JWT del Control Maestro (login propio).
> Header: `Authorization: Bearer <master_jwt_token>`

### M-1 Auth

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-1a | `/api/v1/master/auth/login` | POST | Login del Control Maestro |
| M-1b | `/api/v1/master/auth/me` | GET | Info del usuario logueado |

### M-2 Dashboard

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-2a | `/api/v1/master/dashboard/stats` | GET | KPIs generales |
| M-2b | `/api/v1/master/dashboard/charts` | GET | Datos para gráficas |
| M-2c | `/api/v1/master/dashboard/activity` | GET | Timeline de actividad |

### M-3 Clients

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-3a | `/api/v1/master/clients` | GET | Listar todos los clientes |
| M-3b | `/api/v1/master/clients/{id}` | GET | Detalle de cliente |
| M-3c | `/api/v1/master/clients/{id}/toggle` | PUT | Activar/Desactivar |
| M-3d | `/api/v1/master/clients/{id}/plan` | PUT | Cambiar plan |

### M-4 Tickets

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-4a | `/api/v1/master/tickets` | GET | Listar tickets |
| M-4b | `/api/v1/master/tickets` | POST | Crear ticket |
| M-4c | `/api/v1/master/tickets/{id}` | GET | Detalle del ticket |
| M-4d | `/api/v1/master/tickets/{id}` | PUT | Actualizar ticket |
| M-4e | `/api/v1/master/tickets/{id}/assign` | PUT | Asignar a miembro |
| M-4f | `/api/v1/master/tickets/{id}/messages` | GET | Mensajes del ticket |
| M-4g | `/api/v1/master/tickets/{id}/messages` | POST | Enviar mensaje |

### M-5 Operations

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-5a | `/api/v1/master/ops/force-close-session` | POST | Forzar cierre de sesión |
| M-5b | `/api/v1/master/ops/block-user` | PUT | Bloquear usuario |
| M-5c | `/api/v1/master/ops/adjust-balance` | PUT | Ajustar saldo |

### M-6 Team

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-6a | `/api/v1/master/team` | GET | Listar miembros |
| M-6b | `/api/v1/master/team` | POST | Invitar miembro |
| M-6c | `/api/v1/master/team/{id}` | GET | Perfil del miembro |
| M-6d | `/api/v1/master/team/{id}/performance` | GET | Métricas de rendimiento |
| M-6e | `/api/v1/master/team/{id}` | PUT | Actualizar miembro |

### M-7 Billing

| ID | Endpoint | Método | Descripción |
|----|----------|--------|-------------|
| M-7a | `/api/v1/master/billing/summary` | GET | Resumen financiero |
| M-7b | `/api/v1/master/billing/invoices` | GET | Lista de facturas |
| M-7c | `/api/v1/master/billing/invoices` | POST | Generar factura |
| M-7d | `/api/v1/master/billing/plans` | GET | Planes disponibles |

---

## Swagger

Documentación interactiva disponible en:
```
http://localhost:8080/swagger-ui/index.html
```

API docs (OpenAPI 3.0):
```
http://localhost:8080/v3/api-docs
```
