# Flujo Completo del Sistema — Taco'Os

> *Mapa visual de todos los flujos del sistema. Fase I.*

---

## 1. Flujo de Inicio — Onboarding QR

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLUJO DE INICIO (ONBOARDING)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  USUARIO NUEVO                                                              │
│  ─────────────                                                              │
│  1. Descarga la app                                                          │
│  2. Pulsa "Iniciar sesión con Google"                                       │
│  3. Google Sign-In → id_token → Backend                                     │
│  4. Backend crea usuario (role = null)                                      │
│  5. Usuario elige: "Soy Dueño" o "Soy Cajero"                              │
│                                                                             │
│  ┌─────────────────────────┐       ┌─────────────────────────────────────┐  │
│  │    ELIGE DUEÑO          │       │    ELIGE CAJERO                     │  │
│  │    ──────────           │       │    ──────────                       │  │
│  │    → Crea negocio       │       │    → Cámara QR se abre             │  │
│  │    → Nombre, ubicación  │       │    → Escanea QR del Patrón         │  │
│  │    → Horario cierre     │       │    → Se enlaza al negocio          │  │
│  │    → Licencia Free auto │       │    → Va directo a cobrar           │  │
│  │    → Dashboard 3+1+1+🔔 │       │                                     │  │
│  └─────────────────────────┘       └─────────────────────────────────────┘  │
│                                                                             │
│  REGISTRO DEL NEGOCIO (Dueño)                                               │
│  ────────────────────────────                                               │
│  POST /api/v1/business                                                      │
│  {                                                                          │
│    "name": "Taquería Bonita",                                               │
│    "location": "Av. Principal #123",                                        │
│    "closing_time": "23:00",    // opcional                                  │
│    "currency": "MXN",                                                       │
│    "base_cash": 500.00                                                      │
│  }                                                                          │
│                                                                             │
│  Backend crea:                                                              │
│  - Business (con datos)                                                     │
│  - User (role=OWNER, business_id)                                          │
│  - License (plan=FREE, status=ACTIVE)                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Flujo de Venta — Modo Cajero

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE VENTA (MODO CAJERO)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. APERTURA DE CAJA                                                        │
│  ──────────────────                                                         │
│  POST /api/v1/cashier/open-session                                          │
│  {                                                                          │
│    "business_id": "...",                                                    │
│    "cashier_id": "...",                                                     │
│    "opening_balance": 500.00                                                │
│  }                                                                          │
│  → Se crea CashierSession (status=OPEN)                                     │
│  → Se muestra pantalla de cobro                                             │
│                                                                             │
│  2. AGREGAR PRODUCTOS                                                       │
│  ────────────────────                                                       │
│  GET /api/v1/business/{id}/products?category=comida                         │
│  → Se muestra lista de productos de la categoría                            │
│                                                                             │
│  Si la categoría está vacía:                                                │
│  POST /api/v1/business/{id}/products                                        │
│  {                                                                          │
│    "name": "Taco de Suadero",                                               │
│    "price": 28.00,                                                          │
│    "category": "COMIDA"                                                     │
│  }                                                                          │
│  → Solo si el Cajero tiene permiso (permissions.products.create=true)       │
│                                                                             │
│  3. REGISTRAR CANTIDAD                                                      │
│  ──────────────────────                                                     │
│  Popup con nombre del producto + caja de cantidad + teclado 9 dígitos       │
│  → Se agrega a la lista de venta actual                                     │
│  → Se actualiza el total                                                    │
│                                                                             │
│  4. PAGO                                                                    │
│  ─────                                                                      │
│  POST /api/v1/transactions (EFECTIVO)                                       │
│  {                                                                          │
│    "business_id": "...",                                                    │
│    "session_id": "...",                                                     │
│    "type": "SALE",                                                          │
│    "items": [                                                               │
│      { "product_id": "...", "name": "Taco al Pastor", "qty": 3,            │
│        "unit_price": 25.00 }                                                │
│    ],                                                                       │
│    "payment": {                                                             │
│      "method": "CASH",                                                      │
│      "amount_received": 200.00,                                             │
│      "change": 89.00                                                        │
│    },                                                                       │
│    "total": 111.00                                                          │
│  }                                                                          │
│                                                                             │
│  POST /api/v1/transactions (TARJETA)                                        │
│  {                                                                          │
│    ...                                                                      │
│    "payment": {                                                             │
│      "method": "CARD",                                                      │
│      "card_photo_url": "https://storage.tacoos.com/baucher-001.jpg"        │
│    }                                                                        │
│  }                                                                          │
│  → La foto se toma con la cámara de la app                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Flujo de Corte

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLUJO DE CORTE DE CAJA                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. CAJERO PRESIONA "CORTE" EN FOOTER                                      │
│  ─────────────────────────────────────                                      │
│  → Popup: "¿Estás seguro de generar el corte?"                             │
│  → [OK] [Cancelar]                                                          │
│                                                                             │
│  2. SISTEMA MUESTRA RESUMEN AUTOMÁTICO                                      │
│  ─────────────────────────────────────                                      │
│  GET /api/v1/cashier/current-session                                        │
│  → Resumen:                                                                │
│     Ventas:           $7,000                                                │
│     Efectivo:         $4,500                                                │
│     Tarjeta:          $2,500                                                │
│     Gastos:           $1,500                                                │
│     Fondo de caja:      $500                                                │
│     Efectivo esperado: $3,500                                               │
│                                                                             │
│  3. CONTEO MANUAL                                                           │
│  ─────────────────                                                          │
│  "¿Cuánto dinero hay en caja?" → Cajero ingresa monto                      │
│                                                                             │
│  4. CIERRE Y RESULTADO                                                      │
│  ────────────────────                                                       │
│  POST /api/v1/cashier/close-session                                         │
│  {                                                                          │
│    "session_id": "...",                                                     │
│    "actual_cash": 3500.00                                                   │
│  }                                                                          │
│                                                                             │
│  → Si coincide: status = OK                                                 │
│  → Si falta:   status = SHORT → 🔔 al Patrón                              │
│  → Si sobra:   status = OVER  → 🔔 al Patrón                              │
│                                                                             │
│  5. TICKET DIGITAL                                                          │
│  ────────────────                                                           │
│  → Se genera ticket imprimible/compartible (PDF)                           │
│  → Al guardar/compartir, vuelve a pantalla "Abrir Caja"                    │
│                                                                             │
│  AUTO-CIERRE:                                                               │
│  Si hay caja abierta a hora_config + 180 min:                              │
│  → Cierre automático                                                        │
│  → 🔔 al Patrón: "Sucursal X - Turno auto-cerrado"                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Flujo de Cancelación

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE CANCELACIÓN (5 MIN)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. CAJERO SELECCIONA VENTA DESDE "VENTAS DEL DÍA"                        │
│  ─────────────────────────────────────────────────────                      │
│  → Presiona "Cancelar"                                                      │
│                                                                             │
│  2. SISTEMA VERIFICA VENTANA DE 5 MINUTOS                                   │
│  ─────────────────────────────────────────                                  │
│  CancelWindowValidator.validate(transaction)                                │
│  → Si pasaron > 5 min: "Fuera de la ventana de cancelación"                │
│  → Si están dentro: procede                                                │
│                                                                             │
│  3. CAJERO SELECCIONA CAUSA Y TOMA FOTO                                    │
│  ──────────────────────────────────────                                     │
│  POST /api/v1/transactions/{id}/cancel                                      │
│  {                                                                          │
│    "reason": "cliente_se_arrepintio",                                       │
│    "photo": "data:image/jpeg;base64,/9j/4AAQ...",                          │
│    "cashier_id": "..."                                                      │
│  }                                                                          │
│                                                                             │
│  4. SISTEMA PROCESA                                                         │
│  ────────────────                                                           │
│  → Transaction.status = CANCELLED (soft delete)                            │
│  → Se crea registro en tabla Cancellation (con foto)                       │
│  → 🔔 inmediata al Patrón                                                  │
│                                                                             │
│  5. NOTIFICACIÓN AL PATRÓN                                                  │
│  ────────────────────────                                                   │
│  Notification:                                                              │
│  {                                                                          │
│    "type": "CANCELLATION",                                                  │
│    "message": "Cancelación en Taquería Bonita - Pedro.                    │
│               Motivo: cliente se arrepintió.",                              │
│    "data": {                                                                │
│      "transaction_id": "...",                                               │
│      "cashier_name": "Pedro",                                               │
│      "amount": 111.00                                                       │
│    }                                                                        │
│  }                                                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Flujo de Reportes (Patrón)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE REPORTES (PATRÓN)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  5.1 CAJAS ABIERTAS                                                         │
│  ─────────────────                                                          │
│  GET /api/v1/business/{id}/reports/open-sessions                            │
│                                                                             │
│  Lista de cajas activas:                                                    │
│  ┌────────────────────────────────────────────────────┐                     │
│  │  Sucursal: Taquería Bonita                         │                     │
│  │  Cajero: Pedro Páramo                              │                     │
│  │  Abierta: 18:00                                    │                     │
│  │  ────────────────────────────────────────────────  │                     │
│  │  Resumen (desde última sync):                      │                     │
│  │  • 28 transacciones                                │                     │
│  │  • $6,500 vendidos                                 │                     │
│  │  • $1,200 gastados                                 │                     │
│  └────────────────────────────────────────────────────┘                     │
│                                                                             │
│  5.2 LISTA DE CORTES                                                        │
│  ───────────────────                                                        │
│  GET /api/v1/business/{id}/reports/cuts?date=2026-06-10                     │
│                                                                             │
│  Filtros: sucursal | cajero | fecha (día/semana/mes/personalizado)          │
│  ┌────────────────────────────────────────────────────┐                     │
│  │  10 Jun - Pedro - OK                               │                     │
│  │    Ventas: $7,000 | Gastos: $1,500 | Dif: $0      │                     │
│  │  10 Jun - María - OK                               │                     │
│  │    Ventas: $5,200 | Gastos: $800 | Dif: +$50      │                     │
│  └────────────────────────────────────────────────────┘                     │
│                                                                             │
│  5.3 ESTADÍSTICAS                                                           │
│  ────────────────                                                           │
│  GET /api/v1/business/{id}/reports/stats                                    │
│                                                                             │
│  ┌────────────────────────────────────────────────────┐                     │
│  │  Comparativa de semanas:                           │                     │
│  │  ────────────────────────────────────────────────  │                     │
│  │  Semana ACTUAL:  $45,000 vendidos, 320 ventas     │                     │
│  │  Mejor SEMANA:   $52,000 vendidos, 380 ventas     │                     │
│  │  Diferencia:     -13.5% vs mejor semana           │                     │
│  └────────────────────────────────────────────────────┘                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Flujo de Sincronización

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE SINCRONIZACIÓN                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WORKER (cada 5 minutos en segundo plano):                                  │
│  ──────────────────────────────────────────                                 │
│                                                                             │
│  ┌─────────────────┐         POST /api/v1/sync         ┌─────────────────┐  │
│  │   SQLite Local   │ ──────────────────────────────> │   PostgreSQL    │  │
│  │   (Maestra)      │ <────────────────────────────── │   (Consolida)   │  │
│  └─────────────────┘     Respuesta con server_time    └─────────────────┘  │
│                                                                             │
│  Payload enviado:                                                            │
│  {                                                                          │
│    "device_id": "...",                                                      │
│    "business_id": "...",                                                    │
│    "transactions": [...],   // is_synced=false                              │
│    "sessions": [...],       // is_synced=false                              │
│    "products": [...],       // is_synced=false                              │
│    "cuts": [...]            // is_synced=false                              │
│  }                                                                          │
│                                                                             │
│  Resolución de conflictos:                                                  │
│  - Misma transacción desde 2 dispositivos → gana timestamp más reciente    │
│  - Logs inmutables: no se borra nada                                        │
│                                                                             │
│  Offline:                                                                   │
│  - Si no hay conexión → worker reintenta en el próximo ciclo               │
│  - El usuario nunca se entera → todo funciona sin internet                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Flujo de Notificaciones (Patrón 🔔)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE NOTIFICACIONES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TIPOS DE NOTIFICACIÓN EN FASE I:                                           │
│  ─────────────────────────────────                                          │
│                                                                             │
│  ⚠️ CANCELLATION                                                            │
│  Disparador: Cajero cancela una venta (5 min + foto)                       │
│  Datos: transaction_id, cashier_name, amount, motivo                       │
│                                                                             │
│  📊 CUT_DIFFERENCE                                                          │
│  Disparador: Corte con sobrante o faltante                                  │
│  Datos: cut_id, cashier_name, expected, actual, difference                 │
│                                                                             │
│  🕐 AUTO_CLOSE                                                              │
│  Disparador: Caja cerrada por timeout (hora_config + 180 min)              │
│  Datos: session_id, business_name, closed_at                               │
│                                                                             │
│  FLUJO:                                                                     │
│  1. Evento ocurre en el sistema                                            │
│  2. Service crea registro en tabla notifications                           │
│  3. Patrón ve 🔔 con contador de no leídas                                │
│  4. Patrón toca 🔔 → historial de notificaciones                          │
│  5. Patrón puede borrar notificaciones individuales                        │
│                                                                             │
│  GET /api/v1/business/{id}/notifications                                    │
│  DELETE /api/v1/business/{id}/notifications/{id}                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Flujo de Licencias y Upsell

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO DE LICENCIAS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PLANES:                                                                    │
│  ───────                                                                    │
│  ┌──────────┬────────────┬──────────────┬──────────┬────────────┐           │
│  │ Plan     │ Negocios   │ Cajeros/Empl │ IA       │ Precio     │           │
│  ├──────────┼────────────┼──────────────┼──────────┼────────────┤           │
│  │ FREE     │ 1          │ 2 cajeros    │ ❌       │ Gratis     │           │
│  │ PREMIUM  │ 2          │ 5 cajeros    │ ❌       │ $199/mes   │           │
│  │ BUSINESS │ 5          │ 25 empleados │ ✅       │ $499/mes   │           │
│  └──────────┴────────────┴──────────────┴──────────┴────────────┘           │
│                                                                             │
│  TRIAL:                                                                     │
│  ──────                                                                     │
│  POST /api/v1/business/{id}/license/trial                                   │
│  → 14 días de prueba gratis para Premium o Business                        │
│  → Al vencimiento, baja a Free (sin pérdida de datos)                      │
│  → Solo un trial por negocio                                                │
│                                                                             │
│  UPSELL (Sucursales):                                                       │
│  ────────────────────                                                       │
│  Si el Dueño Free quiere agregar una 2da sucursal:                         │
│  → "Alcanzaste el límite de 1 negocio en Free."                            │
│  → "¡Prueba Premium gratis por 14 días!"                                   │
│  → POST /api/v1/business/{id}/license/trial                                │
│                                                                             │
│  VALIDACIÓN AUTOMÁTICA:                                                     │
│  - POST /business → valida max_businesses                                   │
│  - POST /cashiers/invitation → valida max_cashiers                         │
│  → Si excede: error 409 con mensaje de upgrade                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Mapa de Endpoints por Sección

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MAPA DE ENDPOINTS (FASE I)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SEC 8 — AUTH                                                               │
│  POST   /api/v1/auth/login              ← Google Sign-In → JWT              │
│  PUT    /api/v1/auth/role               ← Elegir Dueño o Cajero             │
│                                                                             │
│  SEC 12 — ONBOARDING QR                                                     │
│  POST   /api/v1/business/{id}/cashiers/invitation  ← Generar QR            │
│  POST   /api/v1/business/link-cashier              ← Enlazar por QR        │
│  GET    /api/v1/business/{id}/cashiers             ← Lista cajeros         │
│  DELETE /api/v1/business/{id}/cashiers/{id}         ← Desvincular          │
│                                                                             │
│  SEC 5.1 — APERTURA DE CAJA                                                 │
│  POST   /api/v1/cashier/open-session   ← Abrir caja con fondo              │
│  GET    /api/v1/cashier/current-session ← Ver caja abierta                 │
│                                                                             │
│  SEC 5.2 — PRODUCTOS                                                        │
│  GET    /api/v1/business/{id}/products  ← Listar (filtro categoría)        │
│  POST   /api/v1/business/{id}/products  ← Crear                           │
│  PUT    /api/v1/business/{id}/products/{id} ← Editar                      │
│  DELETE /api/v1/business/{id}/products/{id} ← Eliminar                     │
│                                                                             │
│  SEC 5.5/5.6/5.7 — TRANSACCIONES                                            │
│  POST   /api/v1/transactions            ← Venta/Gasto                      │
│  GET    /api/v1/transactions/{id}       ← Ver transacción                  │
│                                                                             │
│  SEC 7 — CANCELACIÓN                                                        │
│  POST   /api/v1/transactions/{id}/cancel ← Cancelar (5 min + foto)         │
│                                                                             │
│  SEC 6 — CORTE                                                              │
│  POST   /api/v1/cashier/close-session   ← Corte con conteo manual          │
│                                                                             │
│  SEC 4.2 — REPORTES                                                         │
│  GET    /api/v1/business/{id}/reports/open-sessions ← Cajas abiertas       │
│  GET    /api/v1/business/{id}/reports/cuts          ← Lista cortes         │
│  GET    /api/v1/business/{id}/reports/stats         ← Estadísticas         │
│                                                                             │
│  SEC 4.6 — NOTIFICACIONES                                                   │
│  GET    /api/v1/business/{id}/notifications         ← Historial 🔔        │
│  DELETE /api/v1/business/{id}/notifications/{id}    ← Eliminar 🔔         │
│                                                                             │
│  SEC 3.3 — LICENCIAS                                                        │
│  GET    /api/v1/plans                   ← Listar planes                    │
│  GET    /api/v1/business/{id}/license   ← Ver licencia actual              │
│  POST   /api/v1/business/{id}/license/upgrade ← Mejorar plan              │
│  POST   /api/v1/business/{id}/license/trial   ← Activar 14 días trial     │
│                                                                             │
│  SEC 10 — SINCRONIZACIÓN                                                    │
│  POST   /api/v1/sync                    ← Batch cada 5 min                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Mapa de Capas del Backend

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ARQUITECTURA DEL BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  HTTP REQUEST                                                               │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  CONTROLLER LAYER                                                   │    │
│  │  • Solo recibe HTTP, delega al Service                             │    │
│  │  • Valida DTOs con @Valid (Jakarta)                                 │    │
│  │  • Devuelve ResponseEntity<ResponseType>                            │    │
│  └─────────────────────────────┬───────────────────────────────────────┘    │
│                                │                                            │
│                                ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  SERVICE LAYER                                                      │    │
│  │  • Lógica de negocio                                                │    │
│  │  • Interface + Impl (separados)                                     │    │
│  │  • @Transactional en cada método público                           │    │
│  │  • Llama a Validators antes de persistir                           │    │
│  └──────────┬────────────────────────┬────────────────────────────────┘    │
│             │                        │                                     │
│             ▼                        ▼                                     │
│  ┌──────────────────┐  ┌──────────────────────────────────────────┐        │
│  │  VALIDATOR        │  │  MAPPER (MapStruct)                      │        │
│  │  • Stateless      │  │  • Request → Entity                      │        │
│  │  • Bean Spring    │  │  • Entity → Response                     │        │
│  │  • 1 responsab.   │  │  • componentModel = "spring"            │        │
│  └──────────────────┘  └──────────────────────────────────────────┘        │
│             │                        │                                     │
│             ▼                        ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  REPOSITORY LAYER                                                   │    │
│  │  • Spring Data JPA (JpaRepository)                                  │    │
│  │  • Mock: H2 / Real: PostgreSQL                                      │    │
│  │  • CRUD + queries custom                                            │    │
│  └─────────────────────────────┬───────────────────────────────────────┘    │
│                                │                                            │
│                                ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  DATABASE                                                          │    │
│  │  • PostgreSQL (producción)                                          │    │
│  │  • H2 (desarrollo/mock)                                             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```
