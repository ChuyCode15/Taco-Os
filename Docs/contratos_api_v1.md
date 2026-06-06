# Contratos API — Taco'Os v1

**Filosofía:** Competimos contra la libreta, no contra sistemas contables.  
Cada JSON debe ser entendible por un cajero, no por un contador.

| Equipo | Rol |
|--------|-----|
| Jesús | Backend — implementa estos contratos en Spring Boot |
| Fanner | Flutter — consume estos contratos desde la app |
| Leandro | Valida que los datos sirvan para ML futuro |

---

## 1. Login

Intercambia el token de Google por un JWT del sistema.

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
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Juan Ramos",
    "email": "juan@email.com",
    "role": null,
    "has_business": false
  }
}
```

> Si es primera vez que el usuario inicia sesión, se crea automáticamente.  
> El campo `role` viene `null` porque aún no lo ha elegido.

---

## 2. Asignar Rol

Después del login, el usuario elige si es Dueño o Cajero.

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
  "role": "cashier",
  "business_code": "TACO-AB12"  
}
```

**Response — Cajero:**
```json
{
  "redirect_to": "pantalla_venta",
  "business_id": "550e8400-e29b-41d4-a716-446655440001"
}
```

> El `business_code` lo obtiene el cajero del código QR del negocio.  
> No hay formularios ni configuraciones. Elige y ya está dentro.

---

## 3. Crear Negocio

El dueño crea su negocio. Solo datos esenciales.

### `POST /api/v1/business`

**Request:**
```json
{
  "name": "Taquería Bonita",
  "plan": "free",
  "base_cash": 500.00,
  "currency": "MXN"
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Taquería Bonita",
  "plan": "free",
  "base_cash": 500.00,
  "currency": "MXN",
  "cashiers_count": 0,
  "max_cashiers": 2,
  "max_businesses": 1,
  "created_at": "2026-06-05T10:00:00Z"
}
```

> `base_cash` es el dinero que se deja siempre en caja para dar cambio.  
> `max_cashiers` y `max_businesses` dependen del plan.

---

## 4. Productos

Listar y crear productos del negocio.

### `GET /api/v1/business/{id}/products`

**Response:**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440010",
    "name": "Taco al Pastor",
    "price": 25.00,
    "category": "Tacos"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440011",
    "name": "Coca-Cola",
    "price": 18.00,
    "category": "Bebidas"
  }
]
```

### `POST /api/v1/business/{id}/products`

**Request:**
```json
{
  "name": "Taco de Suadero",
  "price": 28.00,
  "category": "Tacos"
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440012",
  "name": "Taco de Suadero",
  "price": 28.00,
  "category": "Tacos"
}
```

> Este endpoint también se usa para la **creación al vuelo**:  
> el cajero escribe "Taco de Suadero, $28" y la app lo crea ahí mismo.

---

## 5. Registrar Transacción

**El endpoint más importante del sistema.**  
Con uno solo manejamos ventas, gastos y deudas.  
Todo cabe aquí, nada de endpoints separados.

### `POST /api/v1/transactions`

**Ejemplo — Venta en efectivo:**
```json
{
  "business_id": "550e8400-e29b-41d4-a716-446655440001",
  "type": "sale",
  "cashier_id": "550e8400-e29b-41d4-a716-446655440002",
  "device_id": "dispositivo-caja-01",
  "customer_phone": "525512345678",
  "items": [
    { "product_id": "uuid-1", "name": "Taco al Pastor", "qty": 3, "unit_price": 25.00 },
    { "product_id": "uuid-2", "name": "Coca-Cola", "qty": 2, "unit_price": 18.00 }
  ],
  "payment": {
    "method": "cash",
    "amount_received": 200.00,
    "change": 89.00
  },
  "total": 111.00,
  "ticket_folio": "V-00042",
  "timestamp": "2026-06-05T20:15:00Z",
  "is_synced": false
}
```

**Ejemplo — Venta con tarjeta (solo foto del baucher):**
```json
{
  "business_id": "uuid",
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
  "ticket_folio": "V-00043",
  "timestamp": "2026-06-05T20:30:00Z",
  "is_synced": false
}
```

**Ejemplo — Gasto:**
```json
{
  "business_id": "uuid",
  "type": "expense",
  "cashier_id": "uuid",
  "device_id": "dispositivo-caja-01",
  "items": [
    { "name": "Compra de carne en mercado", "qty": 1, "unit_price": 850.00 }
  ],
  "total": 850.00,
  "category": "insumos",
  "timestamp": "2026-06-05T07:00:00Z",
  "is_synced": false
}
```

**Ejemplo — Deuda:**
```json
{
  "business_id": "uuid",
  "type": "debt",
  "cashier_id": "uuid",
  "items": [
    { "name": "Proveedor de pasteles", "qty": 1, "unit_price": 10000.00 }
  ],
  "total": 10000.00,
  "due_date": "2026-06-30",
  "creditor": "Pastelería La Mejor",
  "timestamp": "2026-06-05T10:00:00Z",
  "is_synced": false
}
```

**Response (para todos los casos):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "ticket_folio": "V-00042",
  "status": "completed",
  "timestamp": "2026-06-05T20:15:00Z"
}
```

> **Notas técnicas:**
> - `customer_phone` es **opcional**. Si está vacío, es venta sin cliente (sin recibo, sin puntos).
> - `items` siempre es un array. Para gastos simples, un solo item con `qty: 1`.
> - `is_synced: false` cuando se crea offline. El backend lo cambia a `true` al recibirlo en `/sync`.
> - La foto del baucher se toma desde la cámara de la app, se sube a storage y se guarda la URL.

---

## 6. Sincronización Batch

El dispositivo envía todo lo que tiene pendiente.

### `POST /api/v1/sync`

**Request:**
```json
{
  "device_id": "dispositivo-caja-01",
  "business_id": "550e8400-e29b-41d4-a716-446655440001",
  "transactions": [
    {
      "local_id": "uuid-local-01",
      "type": "sale",
      "items": [],
      "total": 111.00,
      "payment": { "method": "cash" },
      "customer_phone": "525512345678",
      "timestamp": "2026-06-05T20:15:00Z"
    }
  ],
  "products": [
    {
      "local_id": "uuid-local-p01",
      "name": "Taco de Suadero",
      "price": 28.00,
      "category": "Tacos",
      "created_at": "2026-06-05T19:00:00Z"
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

## 7. Reporte Simple

Ingresos vs egresos en un rango de fechas. Nada de Excel.

### `GET /api/v1/business/{id}/reports?start_date=2026-06-01&end_date=2026-06-05`

**Response:**
```json
{
  "period": "2026-06-01 to 2026-06-05",
  "cash_balance": {
    "total_sales": 15450.00,
    "total_expenses": 3200.00,
    "total_debts": 10000.00,
    "net_cash": 12250.00,
    "cash_in_register": 4500.00,
    "base_cash": 500.00,
    "withdrawable": 4000.00
  },
  "sales_count": 84,
  "top_products": [
    { "name": "Tacos al Pastor", "quantity": 120, "revenue": 3000.00 },
    { "name": "Coca-Cola", "quantity": 45, "revenue": 810.00 }
  ],
  "payment_methods": {
    "cash": 12000.00,
    "card": 3450.00
  }
}
```

> `withdrawable` es lo que el dueño puede sacar de caja:  
> `cash_in_register - base_cash` (siempre se deja cambio).

---

## 8. Licencia del Negocio

Cada negocio tiene una licencia que controla su plan, vencimiento y límites.

### `GET /api/v1/business/{id}/license`

Muestra el estado actual de la licencia.

**Response:**
```json
{
  "plan": "premium",
  "status": "active",
  "start_date": "2026-06-01",
  "end_date": "2026-12-31",
  "days_remaining": 120,
  "max_cashiers": 5,
  "current_cashiers": 2,
  "max_businesses": 2,
  "current_businesses": 1,
  "features": [
    "whatsapp_receipts",
    "loyalty_program",
    "detailed_reports",
    "ai_insights",
    "ai_purchase_prediction"
  ]
}
```

### `GET /api/v1/plans`

Lista los planes disponibles.

**Response:**
```json
[
  {
    "name": "free",
    "price": 0,
    "max_cashiers": 2,
    "max_businesses": 1,
    "features": ["whatsapp_receipts", "loyalty_program", "basic_reports"]
  },
  {
    "name": "premium",
    "price": 199.00,
    "currency": "MXN",
    "interval": "month",
    "max_cashiers": 5,
    "max_businesses": 2,
    "features": ["whatsapp_receipts", "loyalty_program", "detailed_reports", "ai_insights", "ai_purchase_prediction"]
  }
]
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

> **Validaciones automáticas del backend:**
> - `POST /business` → verifica que no se exceda `max_businesses`
> - `POST /auth/role` (cajero) → verifica que no se exceda `max_cashiers`
> - Si un Premium vence → baja a Free automáticamente. Los datos no se pierden.

---

## 9. Cancelar Venta

Solo dentro de los primeros 3 minutos.

### `POST /api/v1/transactions/{id}/cancel`

**Request:**
```json
{
  "reason": "cliente_se_arrepintio",
  "photo": "data:image/jpeg;base64,/9j/4AAQ...",
  "cashier_id": "550e8400-e29b-41d4-a716-446655440002"
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

> Motivos posibles: `cliente_se_arrepintio`, `producto_equivocado`, `error_cajero`, `otro`.  
> La foto es **obligatoria**. El dueño recibe un push al instante.

---

## Resumen para el equipo

| Endpoint | Método | Jesús (Backend) | Fanner (Flutter) |
|----------|--------|-----------------|------------------|
| `/auth/login` | POST | Validar Google token, generar JWT, crear usuario si nuevo | Google Sign-In, enviar token, guardar JWT en SecureStorage |
| `/auth/role` | PUT | Asignar rol, validar business_code si es cajero | UI de selección Dueño/Cajero |
| `/business` | POST | Crear negocio + licencia Free automática | Formulario mínimo (solo nombre) |
| `/plans` | GET | Listar planes disponibles | Mostrar en pantalla de upgrade |
| `/business/{id}/license` | GET | Devolver licencia actual con límites | Dashboard de licencias para el dueño |
| `/business/{id}/license/upgrade` | POST | Validar pago, activar Premium, actualizar límites | Integrar con pasarela de pago |
| `/products` | GET/POST | CRUD básico | Lista en pantalla de venta, crear al vuelo |
| `/transactions` | POST | **Endpoint universal.** Un solo método para todo | Capturar venta/gasto/deuda, enviar |
| `/sync` | POST | Recibir batch, resolver conflictos (timestamp gana) | Worker cada 5-10 min, enviar pendientes |
| `/reports` | GET | Agregar ventas/gastos/deudas del período | Mostrar en "¿Cómo voy?" |
| `/transactions/{id}/cancel` | POST | Validar 3 min, guardar foto, push al dueño | UI de cancelación con cámara |

---

*Documento de contratos API v1 — Taco'Os*  
*Competimos contra la libreta. Cada JSON, simple.*
