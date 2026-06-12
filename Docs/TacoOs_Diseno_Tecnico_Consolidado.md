# Documento de Diseño Técnico Consolidado: Taco'Os

> *Versión Fase I — Junio 2026*

---

## 1. Misión y Propósito Estratégico

**Misión:** Democratizar la inteligencia financiera para micro-negocios informales.

**Propósito:** Transformar la gestión de negocios desde la intuición hacia la toma de decisiones informada, garantizando la salud financiera y evitando el cierre por desinformación.

**Filosofía:** "Finanzas como el alma del negocio". El sistema debe ser un aliado silencioso: analiza, alerta y sugiere, sin abrumar. Soluciones simples, adecuadas y sin fricción técnica.

**Sector:** Micro-negocios informales — el nicho olvidado por el software empresarial tradicional.

**Competencia:** La libreta de papel. No competimos contra sistemas contables.

---

## 2. Arquitectura del Sistema (Offline-First)

El sistema opera bajo un modelo de **Sincronización Diferida** donde la base de datos local es la maestra y el servidor es el esclavo.

### 2.1 Persistencia y Sincronización

| Capa | Tecnología | Función |
|------|-----------|---------|
| **Local-First** | SQLite / Room | Base de datos maestra en el dispositivo. Cada venta/gasto se registra localmente al instante (latencia cero). |
| **Backend Cloud** | Spring Boot + PostgreSQL | Consolidador de datos, generador de reportes, gestor de licencias. |
| **Sincronización** | Background Sync cada 5 min | Worker envía transacciones pendientes en batch al detectar red estable. |
| **Consistencia** | Backend como consolidador | El dueño ve el estado real del negocio desde su sesión. |

**Flujo de sincronización:**
1. Registro local inmediato (latencia 0).
2. Intento de sincronización con backend cada 5 minutos.
3. Si no hay conexión, el usuario continúa operando sin interrupción.
4. Al recuperar conexión, se envían transacciones pendientes vía batch update.
5. En caso de conflicto (misma transacción desde 2 dispositivos), gana la de timestamp más reciente.

### 2.2 Capas del Sistema (Fase I)

| Capa | Módulo | Función |
|------|--------|---------|
| **Transaccional** | Ventas, Gastos | Registro local inmediato, pago efectivo/tarjeta con foto |
| **Sesión** | Apertura/Cierre de Caja | Control de turno con fondo de cambio |
| **Corte** | Corte diario | Resumen, conteo manual, sobrante/faltante, ticket |
| **Sync** | Batch cada 5 min | Envío de datos pendientes al servidor |
| **Licencias** | Free/Premium/Business | Validación de límites por plan |

---

## 3. Tenant + Control de Licencias (Multitenant)

### 3.1 Arquitectura Multitenant

Cada **negocio** es un **tenant independiente**. Los datos están aislados por `business_id`.
No hay subdominios ni bases de datos separadas — el `business_id` en cada tabla garantiza el aislamiento.

```
Taco'Os (1 app, 1 BD, 1 backend)
  ├── Taquería Bonita (tenant_id = A)
  │   ├── Dueño: Juan
  │   ├── Cajero: Pedro
  │   └── Cajero: María
  ├── Taquería El Faraón (tenant_id = B)
  │   ├── Dueño: Carlos
  │   └── Cajero: Luis
  └── Nevería La Michoacana (tenant_id = C)
      └── Dueño: Lupita
```

### 3.2 Planes y Límites

| Plan | Negocios | Cajeros/Empleados | IA Características | Precio |
|------|----------|-------------------|-------------------|--------|
| **FREE** | 1 | 2 cajeros | ❌ Sin IA | Gratis |
| **PREMIUM** | 2 | 5 cajeros | ❌ Sin IA | $199/mes |
| **BUSINESS** | 5 | 25 empleados | ✅ IA completa | $499/mes |

### 3.3 14 Días de Prueba Gratis (Trial)

- El usuario puede activar un trial de 14 días para **Premium** o **Business**.
- Durante el trial, tiene acceso a todas las funciones del plan seleccionado.
- Al vencimiento del trial, el plan baja automáticamente a Free (sin pérdida de datos).
- Solo se permite **un trial por negocio**.
- El dueño ve en su dashboard: *"Te quedan X días de prueba. ¡Aprovecha!"*.

### 3.4 Validaciones Técnicas por Licencia

El backend valida en cada request que afecte límites:

```
POST /business → valida que no exceda max_businesses
POST /cashiers/invitation → valida que no exceda max_cashiers
```

**Respuesta de error cuando se excede un límite:**
```json
{
  "error": "license_limit_reached",
  "message": "Alcanzaste el límite de cajeros para tu plan actual (máx. 2). Mejora a Premium.",
  "current": 2,
  "limit": 2,
  "upgrade_required": "premium"
}
```

---

## 4. UX/UI — Dashboard Patrón (3+1+1+🔔)

El Dashboard del Patrón sigue el modelo **3+1+1+🔔**: 3 botones principales, un engrane de ajustes, un menú de perfil y una campanita de notificaciones.

```
┌──────────────────────────────────────────┐
│  ☰              🔔                  ⚙️  │
├──────────────────────────────────────────┤
│                                          │
│     [ 💰 VENTAS → Modo Cajero ]         │
│                                          │
│     [ 📈 REPORTES ]                      │
│                                          │
│     [ 👥 EQUIPO ]                        │
│                                          │
└──────────────────────────────────────────┘
```

### 4.1 Ventas → Modo Cajero
- Botón principal que activa el **Toggle a Modo Cajero**.
- El Patrón puede cobrar directamente sin cambiar de rol.
- Si ya hay una caja abierta, entra directo a la pantalla de cobro.
- Si no hay caja abierta, solicita apertura con fondo de cambio.
- Al volver al Dashboard Patrón, muestra una alerta: *"Caja abierta. Recuerda cerrar tu corte."*.

### 4.2 Reportes
Tres subsecciones:

| Subsección | Contenido |
|------------|-----------|
| **Cajas Abiertas** | Lista de cajas activas por sucursal y cajero. Al seleccionar una, muestra transacciones del turno activo con barra fija de resumen (ventas, gastos, total transacciones). |
| **Lista de Cortes** | Historial de cortes con filtros por sucursal, cajero y fecha (día, semana, mes, período personalizado). |
| **Estadísticas** | Comparativa de la mejor semana vs la semana activa. |

### 4.3 Equipo
- Lista de cajeros enlazados con nombre, email y estado (caja abierta/cerrada).
- Botón **"Registrar Nuevo"**: genera un QR de invitación temporal.
- Botón **"Desvincular"**: requiere confirmación con paso de seguridad (popup con motivo) para evitar despidos accidentales.

### 4.4 ⚙️ Ajustes
| Opción | Descripción |
|--------|-------------|
| **Productos** | CRUD del catálogo del negocio. Categorías fijas: Comida, Bebidas, Postres. |
| **Sucursales** | Gestión de sucursales. Si el plan Free tiene 1 y quiere agregar otra, muestra upsell con trial de 14 días. |
| **Mi Plan** | Panel de licencia: plan actual, vencimiento, límites usados vs totales, botón de mejora. |

### 4.5 ☰ Menú de Perfil
- **Perfil**: Datos personales del usuario (nombre, email, teléfono).
- **Dark Mode**: Alternancia entre tema claro y oscuro.
- **Ayuda**: Soporte y contacto.

### 4.6 🔔 Notificaciones
Las notificaciones se muestran en una campanita con contador de no leídas.

| Tipo de Notificación | Disparador |
|----------------------|------------|
| ⚠️ **Cancelación** | Cajero cancela una venta (5 min, con foto) |
| 📊 **Corte con diferencia** | Sobrante o faltante detectado en el conteo manual del corte |
| 🕐 **Auto-cierre** | Caja cerrada automáticamente por timeout (hora configurada + 180 min) |

El Patrón puede ver el historial de notificaciones y borrarlas individualmente.

---

## 5. UX/UI — Modo Cajero

### 5.1 Apertura de Caja
Al entrar al Modo Cajero sin una caja activa, se muestra:
- Botón grande **"Abrir Caja"**.
- Popup: *"¿Cuánto dinero dejas de fondo para dar cambio?"* (campo numérico).
- Al confirmar, se abre la sesión de caja y se habilita la pantalla de cobro.

### 5.2 Catálogo de Productos
Tres categorías fijas (no configurables por el usuario en Fase I):

| Categoría | Ejemplos |
|-----------|----------|
| **Comida** | Tacos al Pastor, Suadero, Quesadillas |
| **Bebidas** | Coca-Cola 600ml, Agua, Jarritos |
| **Postres** | Flan, Helado, Pastel |

- Por defecto se muestra la categoría **Comida**.
- Al seleccionar un producto de la lista, se abre un popup con el nombre del producto, una caja de texto para cantidad y el **teclado numérico de 9 dígitos**.

### 5.3 Productos al Vuelo
- Si la categoría está vacía (primera vez), se muestra el botón **"Registrar Producto"**.
- Popup con: Nombre, Categoría (fija), Precio, Foto (opcional desde galería o cámara).
- **Solo disponible si el Cajero tiene permiso del Patrón** para crear productos.

### 5.4 Teclado Numérico
- Teclado de 9 dígitos (1-9) más 0, diseñado específicamente para entrada rápida de cantidades.
- Al seleccionar un producto: popup con nombre, caja de cantidad y teclado numérico.
- Al presionar "Aceptar", el producto se agrega a la lista de venta actual.

### 5.5 Pago — Efectivo
- Botón **"Cobrar"** → Popup con dos opciones: Efectivo / Tarjeta.
- **Efectivo:** Cajero ingresa el monto con que paga el cliente, la app calcula el cambio automáticamente.
- La venta se registra como pago en efectivo.

### 5.6 Pago — Tarjeta
- **Tarjeta:** Se abre la cámara para tomar foto del baucher/voucher como comprobante.
- No hay integración con terminal bancaria (la terminal es del cliente).
- La venta se registra como pago con tarjeta (no afecta el efectivo en caja).

### 5.7 Footer del Cajero
Tres botones fijos en la parte inferior:

| Botón | Función |
|-------|---------|
| **Ventas** | Registra una nueva venta (es el botón principal de acción) |
| **Gastos** | Popup con campos: cantidad, detalle, ¿para qué?, ¿quién? |
| **¿Cómo voy?** | Vista previa al corte: total de ventas, gastos, métodos de pago del turno activo |

---

## 6. Corte y Cierre de Caja

### 6.1 Corte Manual
Al presionar **"Corte"** en el Footer:

1. **Confirmación:** *"¿Estás seguro de generar el corte?"* → [OK] [Cancelar].
2. **Resumen automático:**
   ```
   Ventas: $7,000
   Efectivo: $4,500
   Tarjeta: $2,500
   Gastos: $1,500
   Fondo de caja: $500
   Efectivo esperado en caja: $3,500
   ```
3. **Conteo manual:** *"¿Cuánto dinero hay en caja?"* → Cajero ingresa el monto físico.
4. **Resultado:**
   - Si coincide → Corte exitoso.
   - Si falta → Se registra **faltante** y se genera 🔔 al Patrón.
   - Si sobra → Se registra **sobrante** y se genera 🔔 al Patrón.
5. **Ticket digital:** Resumen del corte en formato imprimible/compartible (PDF o WhatsApp).
6. Al guardar/compartir el ticket, la pantalla vuelve a **"Abrir Caja"** para iniciar un nuevo turno.

### 6.2 Auto-cierre por Timeout
- El Patrón puede configurar una **hora de cierre opcional** al registrar el negocio.
- Si hay una caja abierta a la hora de cierre + 180 minutos:
  1. El sistema cierra la caja automáticamente.
  2. Se genera un reporte de auto-cierre.
  3. Se envía una 🔔 al Patrón: *"Sucursal [nombre] - Turno auto-cerrado por tiempo."*

**Nota:** El auto-cierre y el corte manual **no cierran la sesión del usuario**. La sesión solo se cierra si:
- El usuario cierra sesión manualmente.
- La app permanece en segundo plano por más de 12 horas.

---

## 7. Cancelación (Anti-Fraude)

### 7.1 Reglas
- Ventana de **5 minutos** para cancelar una venta desde su registro.
- Requiere:
  1. Selección de causa (cliente se arrepintió, producto equivocado, error del cajero, otro).
  2. Foto obligatoria del producto devuelto.
  3. Notificación 🔔 inmediata al celular del Patrón.
- Fuera de la ventana de 5 min, la venta no se puede cancelar (solo anulación administrativa por el Patrón, en Fase II).

### 7.2 Flujo de Cancelación
1. Cajero selecciona la venta desde "Ventas del día".
2. Presiona "Cancelar".
3. Sistema verifica que no hayan pasado 5 min desde el timestamp de la venta.
4. Cajero selecciona motivo y toma foto.
5. Backend registra la cancelación (log inmutable, no se borra la venta original).
6. 🔔 al Patrón: *"Cancelación en [Negocio] - [Cajero]. Motivo: [razón]. Ver evidencia."*

---

## 8. Autenticación y Sesión

### 8.1 Google Sign-In
- Login social con Google. Sin formularios ni correos de verificación.
- Al ser primera vez, el backend crea el usuario automáticamente con `role = null`.
- Después del login, el usuario elige si es **Dueño** o **Cajero**.

### 8.2 JWT y Sesión
- JWT con sesión larga: la sesión dura todo el **turno de trabajo**.
- Si la app pasa a segundo plano, el JWT expira después de **12 horas** (requiere re-login).
- **El corte no cierra la sesión.** El usuario puede hacer múltiples cortes en un mismo turno.
- La sesión se cierra manualmente desde ☰ → Cerrar Sesión, o automáticamente por las 12hr en segundo plano.

### 8.3 Seguridad
- SecureStorage en Flutter para mantener sesión activa.
- Cada transacción incluye: `user_id`, `device_id`, `timestamp`.
- Logs inmutables: no se borra nada, solo se cambia status a `cancelled`.

---

## 9. Modelo de Datos — Fase I

### 9.1 Entidades Principales

| Entidad | Propósito | Campos Clave |
|---------|-----------|-------------|
| **Business** | Configuración del negocio | `id`, `name`, `location`, `closing_time` (opcional), `owner_id`, `created_at` |
| **User** | Usuarios del sistema | `id`, `role` (owner/cashier), `google_id`, `name`, `email`, `phone`, `business_id`, `permissions` (JSON: `{products:{create:bool, edit:bool, delete:bool}}`) |
| **CashierSession** | Sesión de caja activa | `id`, `business_id`, `cashier_id`, `opened_at`, `closed_at`, `opening_balance`, `closing_balance`, `status` (open/closed/auto-closed), `is_synced` |
| **Transaction** | Registro de operaciones | `id`, `session_id`, `type` (sale/expense), `total`, `items_json`, `payment_method` (cash/card), `card_photo_url`, `status` (completed/cancelled), `timestamp`, `user_id`, `device_id`, `is_synced` |
| **Product** | Catálogo de productos | `id`, `name`, `price`, `category` (comida/bebidas/postres), `business_id`, `photo_url`, `is_synced` |
| **Cancellation** | Registro de cancelaciones | `id`, `transaction_id`, `reason`, `photo_url`, `cancelled_at`, `cashier_id` |
| **DailyCut** | Corte de caja | `id`, `session_id`, `business_id`, `cashier_id`, `opened_at`, `closed_at`, `total_sales`, `total_expenses`, `cash_sales`, `card_sales`, `opening_balance`, `expected_cash`, `actual_cash`, `difference`, `status` (ok/over/short/auto-closed), `is_synced` |
| **Notification** | Notificaciones al Patrón | `id`, `business_id`, `type` (cancellation/cut_difference/auto_close), `message`, `data_json`, `is_read`, `created_at` |
| **License** | Licencia del negocio | `id`, `business_id`, `plan` (free/premium/business), `status` (active/expired/trial/suspended), `start_date`, `end_date`, `trial_end_date`, `max_businesses`, `max_cashiers`, `features` (JSON), `stripe_subscription_id` |

### 9.2 Esquemas Locales (SQLite)

**Tabla `local_products`:**
```json
{
  "id": "uuid",
  "name": "Tacos al Pastor",
  "price": 25.00,
  "category": "comida",
  "local_created": true
}
```

**Tabla `local_transactions`:**
```json
{
  "id": "uuid",
  "session_id": "uuid",
  "type": "sale",
  "total": 111.00,
  "items_json": "[{\"product_id\":\"uuid\",\"name\":\"Tacos al Pastor\",\"qty\":3,\"price\":25.0}]",
  "payment_method": "cash",
  "amount_received": 200.00,
  "change": 89.00,
  "status": "completed",
  "is_synced": false,
  "timestamp": "2026-06-05T20:15:00Z"
}
```

**Tabla `local_session`:**
```json
{
  "id": "uuid",
  "business_id": "uuid",
  "opened_at": "2026-06-05T18:00:00Z",
  "opening_balance": 500.00,
  "status": "open",
  "is_synced": false
}
```

---

## 10. Sincronización

### 10.1 Worker de Sync
- Se ejecuta cada **5 minutos** en segundo plano.
- Envía un batch con todas las transacciones, productos y sesiones con `is_synced: false`.
- El backend procesa el batch y marca los registros como `is_synced: true`.
- Si no hay conexión, el worker reintenta en el próximo ciclo.

### 10.2 Resolución de Conflictos
- Si dos dispositivos enviaron la misma transacción, gana la de **timestamp más reciente**.
- Los logs son inmutables: no se borra nada. Las cancelaciones solo cambian el status.

---

## 11. Cajero Empleado

### 11.1 Flujo de Ingreso
1. Login con Google.
2. Selecciona rol "Cajero".
3. La app se bloquea y abre la cámara para escanear el QR de invitación del Patrón.
4. Al escanear, se envía el token + datos de perfil (nombre, email, teléfono, device_id).
5. El backend valida el token, asocia el cajero al negocio y devuelve los datos del negocio.
6. La app guarda los datos localmente y redirige a la pantalla de cobro.

### 11.2 Permisos
Al registrar un cajero, el Patrón ve un toggle **"Todos los permisos"** (activado por defecto). Si lo desmarca, se despliegan opciones para personalizar:

| Módulo | Permisos |
|--------|----------|
| **Productos** | ☑ Registrar ☑ Editar ☑ Eliminar |

Los permisos se almacenan en el campo `permissions` (JSON) del User.
El backend y la app local validan estos permisos antes de permitir acciones.

### 11.3 Footer del Cajero
El Cajero empleado tiene el mismo Footer que el Modo Cajero del Patrón:
- **[Ventas]**: Registrar nueva venta.
- **[Gastos]**: Registrar gasto del turno.
- **[¿Cómo voy?]**: Vista previa al corte.

---

## 12. Onboarding QR (Handshake Patrón-Cajero)

### 12.1 Flujo Completo

```
[ CAJERO ]                           [ PATRÓN ]
Login Google                         Login Google
    ↓                                      ↓
Selecciona "Cajero"                  Abre "Equipo" → "Registrar Nuevo"
    ↓                                      ↓
Cámara QR se abre                     Backend valida límite de licencia
automáticamente                             ↓
    ↓                                 Genera QR con token temporal
    └────────── ESCANEA QR ──────────→┘
                    ↓
          POST /api/v1/business/link-cashier
                    ↓
    ┌───────────────┴───────────────┐
    │  Enlace exitoso               │
    │  Cajero: Datos del negocio    │
    │  Patrón: Nombre, email,       │
    │          teléfono del cajero  │
    └───────────────┬───────────────┘
                    ↓
    Cajero → Pantalla de cobro
    Patrón → Cajero agregado a la lista
```

### 12.2 Datos Intercambiados

**QR → Cajero (token encriptado):**
```
tacoos://link?token=INV-550e8400-e29b-a716-999999
```

**Cajero → Backend (POST /link-cashier):**
```json
{
  "invitation_token": "INV-550e8400-e29b-a716-999999",
  "name": "Pedro Páramo",
  "email": "pedro@email.com",
  "phone": "+525598765432",
  "device_id": "android-device-9988"
}
```

**Backend → Cajero (Response):**
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

---

## A1. Fase II — Lealtad y WhatsApp CRM (Pendiente)

*Módulo a desarrollar después de Fase I.*

**Componentes:**
- Registro de cliente con número telefónico.
- Recibos por WhatsApp con acumulación de puntos.
- Programa de lealtad (5 compras = 1 producto gratis).
- Canje de premios con código QR.
- Promociones inteligentes en temporada baja.

---

## A2. Fase III — IA y Reportes Avanzados (Pendiente)

*Módulo a desarrollar después de Fase II.*

**Componentes:**
- Insights personalizados diarios (Premium) y semanales genéricos (Free).
- Proyecciones de flujo de caja a 7/30 días.
- Alerta temprana de riesgo de quiebra.
- Reportes detallados por cajero, producto, hora.
- Alertas de "No registro" vs promedio histórico.

---

## A3. Fase IV — Digitalización QR y Menú (Pendiente)

*Módulo a desarrollar después de Fase III.*

**Componentes:**
- Menú digital con código QR por mesa.
- Pedidos desde el celular del cliente.
- Cola de pedidos en pantalla del cajero.
- Gestión de inventario en tiempo real.

---

## A4. Fase V — Materias Primas (Pendiente)

*Módulo a desarrollar después de Fase IV.*

**Componentes:**
- Reporte diario de sobrantes desde la app del cajero.
- Predicción IA del pedido del día siguiente.
- Integración con calendarios de eventos (partidos, clima, festivos).
- Lista de compras exportable.
