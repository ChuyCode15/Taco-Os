# Contratos API — Taco'Os v1 (Fase I)

**Filosofía:** Competimos contra la libreta, no contra sistemas contables.  
Cada JSON debe ser entendible por un cajero, no por un contador.

| Equipo | Rol |
|--------|-----|
| Jesús | Backend — implementa estos contratos en Spring Boot |
| Fanner | Flutter — consume estos contratos desde la app |
| Leandro | Valida que los datos sirvan para ML futuro |

---

## 5.1 Apertura de Caja

Inicia una sesión de caja con un fondo de cambio.

### `POST /api/v1/cashier/open-session`

**Request:**
```json
{
  "business_id": "550e8400-e29b-41d4-a716-446655440001",
  "cashier_id": "550e8400-e29b-41d4-a716-446655440002",
  "device_id": "dispositivo-caja-01",
  "opening_balance": 500.00
}
```

**Response (201 Created):**
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440030",
  "status": "open",
  "opened_at": "2026-06-05T18:00:00Z",
  "opening_balance": 500.00,
  "is_synced": false
}
```

> `opening_balance` es el dinero que se deja en caja para dar cambio.  
> La sesión queda abierta hasta que se haga un corte manual o auto-cierre.

---

## 5.2 Productos

Catálogo de productos con categorías fijas: `comida`, `bebidas`, `postres`.

### `GET /api/v1/business/{id}/products?category=comida`

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Taco al Pastor",
    "price": 25.00,
    "category": "comida",
    "photo_url": null
  },
  {
    "id": "uuid",
    "name": "Coca-Cola 600ml",
    "price": 18.00,
    "category": "bebidas"
  }
]
```

### `POST /api/v1/business/{id}/products`

**Request:**
```json
{
  "name": "Taco de Suadero",
  "price": 28.00,
  "category": "comida",
  "photo_url": "https://storage.tacoos.com/producto-001.jpg"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid",
  "name": "Taco de Suadero",
  "price": 28.00,
  "category": "comida"
}
```

### `PUT /api/v1/business/{id}/products/{id}`

**Request:**
```json
{
  "name": "Taco de Suadero (nuevo precio)",
  "price": 30.00,
  "category": "comida"
}
```

### `DELETE /api/v1/business/{id}/products/{id}`

**Response:**
```json
{
  "status": "deleted"
}
```

> Las categorías son fijas en Fase I: `comida`, `bebidas`, `postres`.  
> El endpoint de creación al vuelo usa el mismo `POST /products`.

---

## 5.5 Transacciones — Venta en Efectivo

### `POST /api/v1/transactions`

**Request — Venta en efectivo:**
```json
{
  "business_id": "uuid",
  "session_id": "uuid",
  "type": "sale",
  "cashier_id": "uuid",
  "device_id": "dispositivo-caja-01",
  "items": [
    { "product_id": "uuid", "name": "Taco al Pastor", "qty": 3, "unit_price": 25.00 },
    { "product_id": "uuid", "name": "Coca-Cola", "qty": 2, "unit_price": 18.00 }
  ],
  "payment": {
    "method": "cash",
    "amount_received": 200.00,
    "change": 89.00
  },
  "total": 111.00,
  "timestamp": "2026-06-05T20:15:00Z",
  "is_synced": false
}
```

**Response (201 Created):**
```json
{
  "id": "uuid",
  "status": "completed",
  "timestamp": "2026-06-05T20:15:00Z"
}
```

---

## 5.6 Transacciones — Venta con Tarjeta

### `POST /api/v1/transactions`

**Request — Venta con tarjeta:**
```json
{
  "business_id": "uuid",
  "session_id": "uuid",
  "type": "sale",
  "cashier_id": "uuid",
  "device_id": "dispositivo-caja-01",
  "items": [
    { "product_id": "uuid", "name": "Tacos al Pastor", "qty": 5, "unit_price": 25.00 }
  ],
  "payment": {
    "method": "card",
    "amount_received": 125.00,
    "change": 0,
    "card_photo_url": "https://storage.tacoos.com/baucher-001.jpg"
  },
  "total": 125.00,
  "timestamp": "2026-06-05T20:30:00Z",
  "is_synced": false
}
```

> La foto del baucher se toma desde la cámara de la app, se sube a storage y se guarda la URL.
> El pago con tarjeta no afecta el efectivo en caja.

---

## 5.7 Transacciones — Gasto

### `POST /api/v1/transactions`

**Request — Gasto:**
```json
{
  "business_id": "uuid",
  "session_id": "uuid",
  "type": "expense",
  "cashier_id": "uuid",
  "device_id": "dispositivo-caja-01",
  "items": [
    { "name": "Servilletas", "qty": 1, "unit_price": 50.00 }
  ],
  "total": 50.00,
  "description": "Compra de servilletas para el turno",
  "timestamp": "2026-06-05T19:00:00Z",
  "is_synced": false
}
```

> Los gastos son registros de salidas provisionales del turno.

---

## 6 Corte de Caja

Cierra la sesión de caja y genera un corte con conteo manual.

### `POST /api/v1/cashier/close-session`

**Request:**
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440030",
  "cashier_id": "uuid",
  "device_id": "dispositivo-caja-01",
  "actual_cash": 3500.00,
  "notes": "Corte normal, sin novedades"
}
```

**Response:**
```json
{
  "cut_id": "uuid",
  "session_id": "uuid",
  "opened_at": "2026-06-05T18:00:00Z",
  "closed_at": "2026-06-05T23:00:00Z",
  "summary": {
    "total_sales": 7000.00,
    "total_expenses": 1500.00,
    "cash_sales": 4500.00,
    "card_sales": 2500.00,
    "opening_balance": 500.00,
    "expected_cash": 3500.00,
    "actual_cash": 3500.00,
    "difference": 0.00
  },
  "status": "ok",
  "ticket_url": "https://storage.tacoos.com/cuts/cut-001.pdf"
}
```

> `actual_cash` es lo que el cajero cuenta físicamente en la caja.
> `difference` = `actual_cash - expected_cash`. Si es positiva → sobrante, negativa → faltante.
> `status` puede ser: `ok`, `over` (sobrante), `short` (faltante), `auto-closed`.

---

## 7 Cancelación

### `POST /api/v1/transactions/{id}/cancel`

**Request:**
```json
{
  "reason": "cliente_se_arrepintio",
  "photo": "data:image/jpeg;base64,/9j/4AAQ...",
  "cashier_id": "uuid"
}
```

**Response:**
```json
{
  "status": "cancelled",
  "original_total": 111.00,
  "cancelled_at": "2026-06-05T20:17:30Z",
  "owner_notified": true
}
```

> **Ventana de cancelación: 5 minutos** desde el timestamp de la venta.
> Motivos posibles: `cliente_se_arrepintio`, `producto_equivocado`, `error_cajero`, `otro`.
> La foto es **obligatoria**. El dueño recibe una notificación 🔔 al instante.
> **Cancelación Lógica:** La transacción original NO se elimina. Solo cambia su `status` de `COMPLETED` a `CANCELLED`. Se crea un registro independiente en la tabla `cancellations` con motivo, foto y timestamp. Los logs son inmutables.

---

## 8 Autenticación y Sesión

### `POST /api/v1/auth/login`

**Request:**
```json
{
  "google_token": "eyJhbGciOiJSUzI1..."
}
```

**Response:**
```json
{
  "jwt": "eyJhbGciOiJIUzI1...",
  "user": {
    "id": "uuid",
    "name": "Juan Ramos",
    "email": "juan@email.com",
    "role": null,
    "has_business": false
  }
}
```

> Si es primera vez, se crea automáticamente.  
> `role` viene `null` porque aún no lo ha elegido.  
> JWT con sesión larga (turno). Si la app pasa a segundo plano > 12hrs, requiere re-login.

### `PUT /api/v1/auth/role`

**Request — Dueño:**
```json
{
  "role": "owner"
}
```

**Response — Dueño:**
```json
{
  "redirect_to": "dashboard_owner",
  "business_id": null
}
```

**Request — Cajero:**
```json
{
  "role": "cashier"
}
```

> Al seleccionar "cashier", la app abre la cámara para escanear QR.
> El enlace se completa mediante `POST /business/link-cashier`.

---

## 12 Onboarding QR

### 12.1 Generar Invitación (Patrón)

### `POST /api/v1/business/{id}/cashiers/invitation`

**Request:** Vacío (se valida el JWT del dueño).

**Response (201 Created):**
```json
{
  "invitation_token": "INV-550e8400-e29b-a716-999999",
  "expires_at": "2026-06-09T20:45:00Z",
  "qr_payload": "tacoos://link?token=INV-550e8400-e29b-a716-999999"
}
```

> El backend valida que no se exceda `max_cashiers` del plan antes de generar el token.
> El token expira en 15 minutos por seguridad.

### 12.2 Enlazar Cajero (Cajero escanea QR)

### `POST /api/v1/business/link-cashier`

**Request:**
```json
{
  "invitation_token": "INV-550e8400-e29b-a716-999999",
  "name": "Pedro Páramo",
  "email": "pedro@email.com",
  "phone": "+525598765432",
  "device_id": "android-device-9988"
}
```

**Response (200 OK):**
```json
{
  "status": "linked",
  "business": {
    "id": "uuid",
    "name": "Taquería Bonita",
    "currency": "MXN",
    "base_cash": 500.00
  },
  "owner": {
    "name": "Juan Ramos",
    "phone": "+525512345678"
  }
}
```

### 12.3 Lista de Cajeros

### `GET /api/v1/business/{id}/cashiers`

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Pedro Páramo",
    "email": "pedro@email.com",
    "phone": "+525598765432",
    "permissions": {
      "products": { "create": true, "edit": false, "delete": false }
    },
    "has_open_session": true,
    "linked_at": "2026-06-05T18:00:00Z"
  }
]
```

### 12.4 Desvincular Cajero

### `DELETE /api/v1/business/{id}/cashiers/{cashier_id}`

**Request:**
```json
{
  "reason": "despido",
  "confirmed": true
}
```

**Response:**
```json
{
  "status": "unlinked",
  "message": "Cajero desvinculado exitosamente."
}
```

> La desvinculación requiere confirmación con motivo para evitar accidentes.

---

## 10 Sincronización Batch

### `POST /api/v1/sync`

**Request:**
```json
{
  "device_id": "dispositivo-caja-01",
  "business_id": "uuid",
  "transactions": [
    {
      "local_id": "uuid-local-01",
      "type": "sale",
      "items": [],
      "total": 111.00,
      "payment": { "method": "cash" },
      "timestamp": "2026-06-05T20:15:00Z"
    }
  ],
  "sessions": [
    {
      "local_id": "uuid-local-s01",
      "opened_at": "2026-06-05T18:00:00Z",
      "opening_balance": 500.00,
      "status": "open"
    }
  ],
  "products": [
    {
      "local_id": "uuid-local-p01",
      "name": "Taco de Suadero",
      "price": 28.00,
      "category": "comida",
      "created_at": "2026-06-05T19:00:00Z"
    }
  ],
  "cuts": [
    {
      "local_id": "uuid-local-c01",
      "closed_at": "2026-06-05T23:00:00Z",
      "total_sales": 7000.00,
      "actual_cash": 3500.00
    }
  ]
}
```

**Response:**
```json
{
  "synced": 5,
  "failed": 0,
  "conflicts": [],
  "server_time": "2026-06-05T22:30:00Z"
}
```

> **Regla de conflictos:** Si dos dispositivos enviaron la misma transacción, gana la de timestamp más reciente.
> **Logs inmutables:** Nunca se borra nada. Las cancelaciones solo cambian el status.

---

## 4.2 Reportes

### `GET /api/v1/business/{id}/reports/open-sessions`

Lista de cajas abiertas con resumen.

**Response:**
```json
[
  {
    "session_id": "uuid",
    "cashier_name": "Pedro Páramo",
    "branch": "Taquería Bonita",
    "opened_at": "2026-06-05T18:00:00Z",
    "summary": {
      "transaction_count": 28,
      "total_sales": 6500.00,
      "total_expenses": 1200.00
    }
  }
]
```

### `GET /api/v1/business/{id}/reports/cuts?branch=&cashier_id=&start_date=2026-06-01&end_date=2026-06-05`

**Response:**
```json
[
  {
    "cut_id": "uuid",
    "cashier_name": "Pedro Páramo",
    "branch": "Taquería Bonita",
    "opened_at": "2026-06-05T18:00:00Z",
    "closed_at": "2026-06-05T23:00:00Z",
    "total_sales": 7000.00,
    "total_expenses": 1500.00,
    "difference": 0.00,
    "status": "ok"
  }
]
```

### `GET /api/v1/business/{id}/reports/stats`

Comparativa de semanas.

**Response:**
```json
{
  "current_week": {
    "total_sales": 45000.00,
    "total_expenses": 8500.00,
    "transaction_count": 320,
    "avg_ticket": 140.63
  },
  "best_week": {
    "week_of": "2026-05-25",
    "total_sales": 52000.00,
    "total_expenses": 9200.00,
    "transaction_count": 380,
    "avg_ticket": 136.84
  },
  "comparison": {
    "sales_vs_best": -13.46,
    "transactions_vs_best": -15.79
  }
}
```

---

## 4.6 Notificaciones

### `GET /api/v1/business/{id}/notifications`

**Response:**
```json
[
  {
    "id": "uuid",
    "type": "cancellation",
    "message": "Cancelación en Taquería Bonita - Pedro. Motivo: cliente se arrepintió.",
    "data": {
      "transaction_id": "uuid",
      "cashier_name": "Pedro",
      "amount": 111.00
    },
    "is_read": false,
    "created_at": "2026-06-05T20:17:30Z"
  }
]
```

### `DELETE /api/v1/business/{id}/notifications/{id}`

Marca una notificación como eliminada (soft delete).

---

## 3.3 Licencias

### `GET /api/v1/plans`

**Response:**
```json
[
  {
    "name": "free",
    "price": 0,
    "max_businesses": 1,
    "max_cashiers": 2,
    "features": ["basic_reports", "cashier_management"],
    "has_trial": false
  },
  {
    "name": "premium",
    "price": 199.00,
    "currency": "MXN",
    "interval": "month",
    "max_businesses": 2,
    "max_cashiers": 5,
    "features": ["basic_reports", "detailed_reports", "cashier_management", "multiple_branches"],
    "has_trial": true,
    "trial_days": 14
  },
  {
    "name": "business",
    "price": 499.00,
    "currency": "MXN",
    "interval": "month",
    "max_businesses": 5,
    "max_cashiers": 25,
    "features": ["basic_reports", "detailed_reports", "cashier_management", "multiple_branches", "ai_insights"],
    "has_trial": true,
    "trial_days": 14
  }
]
```

### `GET /api/v1/business/{id}/license`

**Response:**
```json
{
  "plan": "free",
  "status": "active",
  "start_date": "2026-06-01",
  "end_date": null,
  "trial_end_date": null,
  "days_remaining": null,
  "max_cashiers": 2,
  "current_cashiers": 1,
  "max_businesses": 1,
  "current_businesses": 1,
  "features": ["basic_reports", "cashier_management"]
}
```

### `POST /api/v1/business/{id}/license/upgrade`

**Request:**
```json
{
  "plan": "premium",
  "payment_method": "stripe"
}
```

**Response:**
```json
{
  "status": "active",
  "plan": "premium",
  "end_date": "2026-12-31",
  "message": "¡Ya eres Premium! Disfruta de tus nuevos beneficios."
}
```

### `POST /api/v1/business/{id}/license/trial`

Activa el período de prueba de 14 días para un plan.

**Request:**
```json
{
  "plan": "premium"
}
```

**Response:**
```json
{
  "status": "trial",
  "plan": "premium",
  "trial_end_date": "2026-06-19",
  "message": "¡14 días de prueba activados! Disfruta de Premium sin costo."
}
```

---

## Resumen de Endpoints Fase I

| Sec | Endpoint | Método | Descripción |
|-----|----------|--------|-------------|
| 5.1 | `/cashier/open-session` | POST | Abrir caja con fondo de cambio |
| 5.2 | `/business/{id}/products` | GET | Listar productos (filtro por categoría) |
| 5.2 | `/business/{id}/products` | POST | Crear producto |
| 5.2 | `/business/{id}/products/{id}` | PUT | Editar producto |
| 5.2 | `/business/{id}/products/{id}` | DELETE | Eliminar producto |
|-|-|-|
| 5.5 | `/transactions` | POST | Registrar venta/gasto |
| 5.6 | `/transactions` | POST | Venta con tarjeta (foto baucher) |
| 6 | `/cashier/close-session` | POST | Corte con conteo manual |
| 7 | `/transactions/{id}/cancel` | POST | Cancelar venta (5 min, con foto) |
| 8 | `/auth/login` | POST | Login con Google |
| 8 | `/auth/role` | PUT | Asignar rol (dueño/cajero) |
| 10 | `/sync` | POST | Sincronización batch |
| 12.1 | `/business/{id}/cashiers/invitation` | POST | Generar QR de invitación |
| 12.2 | `/business/link-cashier` | POST | Enlazar cajero por QR |
| 12.3 | `/business/{id}/cashiers` | GET | Lista de cajeros |
| 12.4 | `/business/{id}/cashiers/{id}` | DELETE | Desvincular cajero |
| 4.2 | `/business/{id}/reports/open-sessions` | GET | Cajas abiertas |
| 4.2 | `/business/{id}/reports/cuts` | GET | Lista de cortes (con filtros) |
| 4.2 | `/business/{id}/reports/stats` | GET | Estadísticas comparativas |
| 4.6 | `/business/{id}/notifications` | GET | Historial de notificaciones |
| 4.6 | `/business/{id}/notifications/{id}` | DELETE | Eliminar notificación |
| 3.3 | `/plans` | GET | Listar planes |
| 3.3 | `/business/{id}/license` | GET | Ver licencia actual |
| 3.3 | `/business/{id}/license/upgrade` | POST | Mejorar plan |
| 3.3 | `/business/{id}/license/trial` | POST | Activar 14 días prueba |
