# Documento de Diseño Técnico Consolidado: Taco'Os

> *Versión consolidada a partir de v1.1, v1.2 y v1.3 — Junio 2026*

---

## 1. Misión y Propósito Estratégico

**Misión:** Democratizar la inteligencia financiera para micro-negocios informales.

**Propósito:** Transformar la gestión de negocios desde la intuición hacia la toma de decisiones informada, garantizando la salud financiera y evitando el cierre por desinformación.

**Filosofía:** "Finanzas como el alma del negocio". El sistema debe ser un aliado silencioso: analiza, alerta y sugiere, sin abrumar. Soluciones simples, adecuadas y sin fricción técnica.

---

## 2. El Mercado y la Oportunidad

**Sector:** Micro-negocios informales — el nicho olvidado por el software empresarial tradicional.

**Ventaja Competitiva (El Ecosistema de 3 Capas):**

1. **WhatsApp + Lealtad + Anti-Fraude (Capa de Fidelización):**
   - El cliente exige su recibo para acumular puntos y obtener premios (ej. "5 compras = 1 taco gratis"). El cajero **no puede ocultar ventas** porque el cliente lo reclamará.
   - El QR de premio por WhatsApp crea una **relación a largo plazo** con el cliente: sabemos qué consume, cuándo, y podemos enviarle promociones en temporadas bajas.
   - En etapa inicial, el campo cliente es opcional, pero un letrero en el negocio (*"¡Gánate tus tacos! Registra tu compra y participa"*) presiona implícitamente al cajero a registrar cada venta.

2. **Interfaz de "3 Botones":** La complejidad técnica reside en el backend; el usuario solo interactúa con tres botones principales de acción inmediata. Cero esfuerzo de aprendizaje.

3. **Modelo de Negocio:** Volumen mediante bajo costo (Freemium con escalabilidad Premium). La data de consumo y lealtad es el activo más valioso a futuro.

---

## 3. Arquitectura del Sistema (Offline-First)

El sistema opera bajo un modelo de **Sincronización Diferida** para garantizar que la app nunca sea un obstáculo operativo.

### 3.1 Persistencia y Sincronización

| Capa | Tecnología | Función |
|------|-----------|---------|
| **Local-First** | SQLite / Room | Base de datos maestra en el dispositivo. Cada venta/gasto se registra localmente al instante (latencia cero). |
| **Backend Cloud** | Spring Boot + PostgreSQL | Consolidador de datos, motor de IA, API REST. |
| **Sincronización** | Background Sync cada 5-10 min | Job Scheduler envía transacciones pendientes en batch update al detectar red estable. |
| **Consistencia** | backend como consolidador | El dueño ve el estado real del negocio desde su sesión, sin importar qué dispositivo registró la operación. |

**Flujo de sincronización:**
1. Registro local inmediato (latencia 0).
2. Intento de sincronización con backend cada 5-10 minutos.
3. Si no hay conexión, el usuario continúa operando sin interrupción.
4. Al recuperar conexión, se envían transacciones pendientes vía batch update.

### 3.2 Capas del Sistema

#### A. Capa de Control Financiero (Backend - Spring Boot)
- **Módulo Transaccional:** Registro de ventas, gastos y deudas (Cuentas por pagar).
- **Motor de Alerta Temprana:** Algoritmo que monitorea el flujo de caja. Si detecta riesgo de quiebra (incapacidad de pago a proveedores o empleados), dispara una alerta contextual con acciones correctivas.
- **Integración de Deudas:** Gestión de pasivos para visualización clara de la capacidad de pago.

#### B. Capa de Inteligencia (Motor IA - Batch Processing)
- **Analítica Progresiva:** La IA solo se activa si el usuario muestra un comportamiento consistente.
- **Nivelación de Consejos:**
  - **Free:** Control básico, flujo de caja, 1 insight semanal (genérico de comunidad).
  - **Premium:** Consejos diarios, análisis de lealtad, proyecciones de flujo, estrategia de compras.

#### C. Capa de Fidelización + Anti-Fraude (El Motor de Lealtad)

Este es el corazón competitivo de Taco'Os. No es solo CRM, es un **ecosistema de lealtad que presiona al cajero a registrar cada venta**.

**El Ciclo de Lealtad (Cómo funciona):**

1. **Registro del cliente:** Al pagar, el cajero ingresa el número del cliente (opcional al inicio). Si el cliente está registrado → recibe su **recibo por WhatsApp**.
2. **Acumulación de compras:** Por cada compra registrada, el cliente acumula puntos. Ej: "5 compras = 1 taco gratis".
3. **Ejemplo de recibo que llega al cliente por WhatsApp:**
   > *Taquería Bonita*
   > *25 Tacos · 2 Cocas = $355*
   > *¡Gracias por cenar con nosotros!*
   > *🎉 Tienes 1 taco gratis en tu próxima visita — presenta este código QR para reclamarlo.*
4. **Canje con QR:** Al alcanzar el premio, el sistema envía el **código QR** al cliente. Lo presenta en mostrador, el cajero lo escanea y se entrega el producto. La transacción queda registrada como canje.
4. **Regreso del cliente:** El cliente vuelve porque sabe que está acumulando. **Relación a largo plazo.**
5. **Datos de consumo:** Sabes qué compra cada cliente, cuándo, a qué hora, y el ticket promedio.
6. **Promociones inteligentes:** El sistema (o la IA después) permite enviar promociones en **temporadas bajas**: *"Martes de 2x1 solo para ti, [Nombre]"*.

**El Efecto Anti-Fraude (Presión Social sobre el Cajero):**

- El cliente **quiere** que su compra sea registrada porque acumula puntos para su premio. Si el cajero no registra la venta (para robarse el efectivo), el cliente **exige su comprobante**.
- **En etapa inicial:** El campo de cliente puede quedar vacío (solo folio de venta, sin recibo). Pero se coloca un **letrero grande en el negocio**: *"¡Gánate tus tacos! Registra tus compras y participa"*. La voz se corre entre los clientes.
- El cajero está **presionado de manera implícita** — si no registra, el cliente lo notará y reclamará.
- El sistema también entrega al dueño **estrategias de cartelería y promoción** basadas en el análisis de datos de todos los negocios (vía IA).

**Valor para cada actor:**
- **Para el cliente:** Recibe premios, promociones, y su comprobante.
- **Para el dueño:** Elimina el fraude del cajero, fideliza clientes, y obtiene datos de consumo.
- **Para el sistema:** Captura masiva de datos transaccionales y de comportamiento para alimentar la IA.

---

## 4. Tenant + Control de Licencias (Multitenant)

### 4.1 Arquitectura Multitenant

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

### 4.2 Control de Licencias (¿Quién es Premium? ¿Cuándo vence?)

Cada tenant tiene una **licencia** que define:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `plan` | Tipo de suscripción | `free`, `premium`, `business` |
| `start_date` | Inicio de la licencia | `2026-06-01` |
| `end_date` | Vencimiento | `null` (Free es perpetuo), `2026-12-31` (Premium) |
| `status` | Estado actual | `active`, `expired`, `trial`, `suspended` |
| `max_cashiers` | Máximo de cajeros permitidos | `2` (Free), `5` (Premium) |
| `max_businesses` | Máximo de negocios | `1` (Free), `2` (Premium) |
| `features` | JSON con características habilitadas | `["whatsapp_receipts", "loyalty", "reports"]` |

**Reglas del sistema:**

- Si la licencia **vence**, el tenant baja automáticamente a Free (pierde funciones Premium, pero no pierde sus datos).
- El sistema **bloquea** acciones que excedan el límite (ej. agregar un 3er cajero en Free muestra: *"Alcanzaste el límite de cajeros. Mejora a Premium."*).
- El dueño ve en su dashboard: **plan actual, fecha de vencimiento (si aplica), y botón para gestionar/mejorar su licencia.**

### 4.3 Dashboard de Licencias (Para el Dueño)

El dueño tiene una sección donde ve:

```
┌─────────────────────────────────┐
│  Plan actual: PREMIUM           │
│  Vence: 31 diciembre 2026       │
│  Estado: ✅ Activo              │
│                                 │
│  Usado:                         │
│  Negocios: 1 de 2               │
│  Cajeros: 2 de 5                │
│                                 │
│  [Mejorar plan]  [Historial]    │
└─────────────────────────────────┘
```

- Si es Free, muestra: *"Estás en Free. Sin fecha de vencimiento."* y botón `[Ver planes]`.
- Si está por vencer (menos de 15 días): muestra alerta amarilla.
- Si ya venció: muestra alerta roja y qué funciones perdió.

### 4.4 Validaciones Técnicas por Licencia

El backend valida en cada request que afecte límites:

```
POST /business → valida que no exceda max_businesses
POST /auth/role (cashier) → valida que no exceda max_cashiers
POST /transactions (para insights) → valida plan antes de generar IA
```

**Respuesta de error cuando se excede un límite:**
```json
{
  "error": "license_limit_reached",
  "message": "Alcanzaste el límite de cajeros para tu plan actual (máx. 2).",
  "current": 2,
  "limit": 2,
  "upgrade_required": "premium",
  "upgrade_url": "/api/v1/plans/premium"
}
```

---

## 5. UX/UI: Simplicidad Radical

La interfaz se rige por la **ley del mínimo esfuerzo** para evitar la fatiga mental.

### 4.1 Dashboard Principal — "Modelo de los 3 Botones"

| Botón | Acción | Descripción |
|-------|--------|-------------|
| **Botón 1: "+"** | Venta | Despliega selección rápida de productos o monto libre. |
| **Botón 2: "-"** | Gasto | Registro rápido de salida de dinero/deuda. |
| **Botón 3: "¿Cómo voy?"** | Visualización | Flujo de Caja y Alertas de IA. Si es Free → solo números. Si es Premium → consejo del día. |

### 4.2 Flujo de Venta (UX Radical)

1. **Entrada de Venta:**
   - *Cliente (Opcional):* Si está vacío → folio genérico (modo inicial, sin recibo). Si se ingresa número → se activa CRM + recibo WhatsApp + acumulación de puntos.
   - *Producto:* Lista de acceso rápido. Si no existe → "Agregar al vuelo" (nombre + precio).
   - *Cálculo:* Botón grande "Cobrar" → Pop-up simple (Total, Pago, Cambio).

2. **Método de Pago (No intrusivo):**
   - **Efectivo:** El cajero registra el monto con que paga el cliente, la app calcula el cambio.
   - **Tarjeta:** Se selecciona "Pago con tarjeta" → se abre la cámara para **tomar foto del baucher/voucher** como comprobante. No hay integración con terminal bancaria (eso queda del lado del cliente).
   - Al final del día, el corte muestra: *Total vendido $10,000 | Tarjeta $2,000 | Efectivo $8,000 | Gastos $3,500 | Efectivo en caja $4,500* (más $500 de base/cambio).

3. **Cierre de Venta:**
   - Guardado local inmediato.
   - Envío a nube en segundo plano.
   - Envío de recibo por WhatsApp al cliente (si registró su número).
   - Si el cliente tiene suficientes compras acumuladas → el sistema le notifica su premio con un código QR canjeable.

### 4.3 Visualización de Resultados — "El Resumen de un Vistazo"

- **Selector de Rango (Calendario de Bolsillo):**
  - Presets: "Hoy", "Ayer", "Esta Semana", "Este Mes".
  - Custom: Selección de fecha inicio y fecha fin.
- **Métricas mostradas:**
  - Total Ventas (Ingresos).
  - Total Gastos (Salidas).
  - Balance Real (Caja): Ingresos - Gastos.
  - Alerta de deudas pendientes si aplica.
- **Indicador de salud:**
  - Balance positivo → tarjeta verde.
  - Balance negativo/en riesgo → tarjeta ámbar/rojo + botón "Ver detalle de gastos".
- **Exportación:** Botón "Compartir" → genera PDF ultra-simple o mensaje formateado para WhatsApp.

### 4.4 Banner de Monetización (No Intrusivo)

- **Ubicación:** Siempre al final de la pantalla "¿Cómo voy?". Nunca al inicio ni interrumpe el flujo operativo.
- **Comportamiento:** Tarjeta "Insight Bloqueado" con icono de IA.
  - Free: Muestra insight genérico de la comunidad (preview).
  - Premium: Muestra insight real y personalizado.
- **Micro-copy aspiracional:** "Desbloquea el análisis de ventas para tu negocio" en lugar de "Hazte Premium".
- **Colores:** Neutros, no rojos alarmistas.

---

## 5. Onboarding y Roles

### 5.1 Registro (Sin Fricción)
- **Login social (Google):** El usuario descarga la app desde Play Store (donde ya tiene sesión con su cuenta Google). Al abrir la app, pulsa "Iniciar sesión con Google" y automáticamente se autentica. No hay formularios, no hay correos de verificación.
- **Elección de rol:** Inmediatamente después del login, el usuario elige si es **Dueño** o **Cajero** y se le redirige a la vista correspondiente. Sin menús de configuración inicial.
- **JWT con caducidad diaria (24h)** para re-validación de sesión.

### 5.2 Roles de Usuario

| Rol | Acceso | Funcionalidades |
|-----|--------|-----------------|
| **Dueño / Patrón** | Dashboard Admin | Crea negocio, define suscripción, añade cajeros, gestiona licencias, auditoría. |
| **Cajero** | Pantalla de Venta | Escanea QR o ingresa número del patrón. Enlace inmediato. Solo vende. |

### 5.3 Configuración "Just-in-Time"
- No hay menús de configuración inicial.
- Si el cajero va a cobrar y no hay productos → la app sugiere: *"¿Qué vas a cobrar hoy?"* y permite crear producto (nombre + precio) en el momento.

---

## 6. Seguridad y Control de Acceso

### 6.1 Autenticación y Sesión
- **JWT** con caducidad de 24 horas.
- **SecureStorage en Flutter** para mantener sesión activa sin re-logueo constante.
- **Re-validación de token** al inicio de cada turno.

### 6.2 Integridad de Datos
- Cada transacción incluye: `user_id`, `device_id`, `timestamp`.
- El log en el backend es **inmutable** — ni el cajero puede borrar registros.

### 6.3 Anti-Fraude (Cancelaciones + Presión Social)

**Cancelaciones:**
- Permitir cancelar **solo dentro de un margen de 3 minutos**.
- Requiere:
  1. Selección de causa (selección rápida).
  2. Foto del producto cancelado (evidencia obligatoria).
  3. Notificación push inmediata al celular del dueño.

**Presión Social (El verdadero anti-fraude):**
- El cliente **quiere** que su compra sea registrada para acumular puntos y recibir su premio. Si el cajero omite el registro, el cliente lo reclamará.
- Letrero visible en el negocio: *"¡Gánate tus tacos! Registra tu compra y participa"* — presión implícita sobre el cajero.
- El dueño recibe reportes de clientes registrados vs. ventas sin cliente — detecta anomalías al instante.

### 6.4 Control de Caja (Corte Diario)

| Concepto | Ejemplo |
|----------|---------|
| Total vendido | $10,000 |
| Cobrado en tarjeta (foto baucher) | $2,000 |
| Cobrado en efectivo | $8,000 |
| Gastos del día | $3,500 |
| Efectivo en caja | $4,500 |
| Base de cambio (siempre fija) | $500 |
| **Efectivo retirable** | **$4,000** |

- El sistema siempre deja una **base fija de cambio** (ej. $500) configurable por el dueño.
- El corte compara las ventas registradas vs. el efectivo físico esperado.

---

## 7. Estructura del Ecosistema (Roadmap Técnico)

| Fase | Enfoque | Entregable Principal |
|------|---------|---------------------|
| **I — Control Operativo** | Pilar transaccional | App Flutter con CRUD de ventas/gastos/deudas y flujo de caja simple. API Spring Boot con soporte Batch Sync. |
| **II — Inteligencia y Fidelización** | IA + CRM | Motor de análisis de datos (batch), CRM WhatsApp (recibos con recompensa + QR), tarjeta de "Insights Premium". El recibo muestra: *"Taquería X, $355, gracias por cenar con nosotros, tienes 1 taco gratis en tu próxima visita."* |
| **III — Digitalización QR** | Punto de venta digital | Menú interactivo QR en mesa, gestión de inventario en tiempo real desde dispositivo del cajero. |
| **IV — Control de Materias Primas** | Abasto inteligente | Reporte diario de sobrantes del cajero → IA predice el pedido del día siguiente según ventas históricas, día de la semana, eventos locales y temporada. |

---

## 8. Módulo de Control de Materias Primas (Fase IV)

### 8.1 El Problema Real

El dueño de una taquería se levanta a las 6 AM para ir al mercado. No sabe exactamente cuánto comprar:
- Si compra de menos, se queda sin insumos en hora pico.
- Si compra de más, se echa a perder la mercancía (carne, cebolla, salsa).
- No considera días atípicos (partidos, días festivos, quincena, temporada baja).

### 8.2 Reporte de Sobrantes (Cierre de Día)

Al final del turno, el cajero hace un **reporte rápido** desde la app de lo que quedó en existencia:

> *"2 cajas de Coca · 20 kg de carne · 2 kg de chorizo · 1 kg de cebolla · lo demás se acabó"*

**Forma de registro:**
- Lista rápida de insumos predefinidos por el dueño (se configura una vez).
- El cajero solo ingresa cantidades sobrantes — si un insumo no aparece, se asume que se terminó.
- Tiempo estimado: menos de 2 minutos.

### 8.3 Predicción Inteligente del Pedido (IA)

Con los datos de:
- Ventas del día + sobrantes reportados
- Historial de ventas del mismo día de la semana
- Día de la semana (viernes, sábado, lunes, etc.)
- Eventos externos (el usuario marca si hay partido, festival, etc. — o la IA aprende patrones)

La IA genera una **recomendación de compra** para el dueño:

**Ejemplo 1 — Viernes de Cuaresma (ventas bajas):**
> *"Mañana es viernes de Cuaresma. Históricamente tus ventas bajan un 30%. Recomendación: compra la mitad del pedido habitual. Tus sobrantes actuales (2 kg carne, 1 kg pollo) cubren el arranque."*

**Ejemplo 2 — Partido de fútbol en el estado (afluencia alta):**
> *"Hay un partido de fútbol a 2 km del negocio. La probabilidad de aumento de clientes es del 75%. Recomendación: lleva un 40% extra de insumos. Si no se vende hoy, tienes para mañana."*

### 8.4 Flujo Completo

1. **Cierre del día:** Cajero reporta sobrantes desde la app (2 min).
2. **IA procesa:** Cruza sobrantes + historial de ventas + día + eventos.
3. **Recomendación al dueño:** Llega notificación (o al abrir la app por la mañana): *"Basado en tus datos, aquí está el pedido sugerido para hoy."*
4. **Dueño decide:** Ajusta cantidades si quiere, confirma o ignora.
5. **Opcional:** El sistema genera una **lista de compras** que el dueño lleva al mercado.

### 8.5 Valor del Módulo

- **Reduce merma:** No se compra de más ni de menos.
- **Ahorra tiempo:** El dueño no tiene que hacer cálculos mentales a las 6 AM.
- **Anticipa demanda:** Aprende de patrones (partidos, quincenas, temporadas).
- **Premium:** Este módulo puede ser parte del plan Premium o un add-on, ya que el dueño que más crece es el que más necesita planificar su abasto.

---

## 10. Modelo de Datos

### 10.1 Entidades Principales

| Entidad | Propósito | Campos Clave |
|---------|-----------|-------------|
| **Business** | Configuración del negocio | `id`, `name`, `plan` (Free/Premium), `owner_id`, `created_at` |
| **User** | Usuarios del sistema | `id`, `role` (owner/cashier), `google_id`, `phone`, `business_id` |
| **Transaction** | Registro de operaciones | `id`, `type` (venta/gasto/deuda), `amount`, `items_json`, `customer_phone`, `is_synced`, `timestamp`, `user_id`, `device_id` |
| **Product** | Catálogo de productos | `id`, `name`, `price`, `category_id`, `business_id`, `is_synced` |
| **Customer** | Clientes para lealtad | `id`, `phone`, `name`, `loyalty_points`, `business_id` |
| **Insight** | Mensajes de IA | `id`, `business_id`, `type` (generic/premium), `message`, `generated_at` |
| **Cancellation** | Registro de cancelaciones | `id`, `transaction_id`, `reason`, `photo_url`, `timestamp`, `cashier_id` |
| **Supply** | Insumos / materias primas | `id`, `business_id`, `name`, `unit_type` (kg, pieza, caja, l), `current_stock`, `low_stock_threshold` |
| **License** | Licencia del negocio | `id`, `business_id`, `plan` (free/premium/business), `status` (active/expired/trial/suspended), `start_date`, `end_date`, `max_cashiers`, `max_businesses`, `features` (JSON), `stripe_subscription_id` |
| **DailyStockReport** | Reporte diario de sobrantes | `id`, `business_id`, `report_date`, `cashier_id`, `items_json` (insumo + cantidad), `is_synced` |
| **PurchaseSuggestion** | Sugerencia de pedido generada por IA | `id`, `business_id`, `generated_at`, `date_for`, `items_json` (insumo + cantidad sugerida), `reason`, `was_used` |

### 10.2 Esquemas para el Cajero (Datos Locales)

**Tabla `LocalProducts`:**
```json
{
  "id": "uuid",
  "name": "Tacos al Pastor",
  "price": 25.00,
  "category_id": "uuid"
}
```

**Tabla `LocalTransactions`:**
```json
{
  "id": "uuid",
  "customer_phone": "5512345678",
  "total": 115.00,
  "items_json": "[{\"product_id\":\"uuid\",\"name\":\"Tacos al Pastor\",\"qty\":3,\"price\":25.0}]",
  "status": "completed",
  "is_synced": false
}
```

### 10.3 Esquema de Lealtad (Rewards)

| Entidad | Propósito | Campos Clave |
|---------|-----------|-------------|
| **LoyaltyProgram** | Configuración del programa | `id`, `business_id`, `purchase_threshold` (ej. 5), `reward_type` (producto específico o monto), `reward_product_id`, `is_active` |
| **CustomerPoints** | Puntos acumulados por cliente | `id`, `customer_id`, `business_id`, `total_purchases`, `purchases_toward_reward`, `rewards_claimed` |
| **RewardRedemption** | Canje de premios | `id`, `customer_id`, `business_id`, `reward_qr_code`, `redeemed_at`, `cashier_id`, `product_id` |

**Flujo de Canje:**
1. Cliente alcanza el umbral de compras (ej. 5).
2. Sistema envía **código QR por WhatsApp**: *"¡Felicidades! Tu taco al pastor + refresco gratis te esperan. Presenta este código en caja."*
3. Cajero escanea el QR → el sistema valida que es válido y no ha sido usado → registra el canje → entrega el producto.
4. El cliente vuelve a empezar a acumular para el siguiente premio.

### 10.4 Esquema de Licenciamiento (ActiveAssets)

| Plan | Límites |
|------|---------|
| **FREE** | 1 Patrón + 2 Cajeros (máx. 1 Negocio) |
| **PREMIUM** | 1 Patrón + 5 Cajeros (máx. 2 Negocios) |
| **BUSINESS** | Multi-Patrón + Ilimitados Cajeros (acceso total) |

**Validación:** Al enlazar un cajero, el backend consulta `count(employees) WHERE business_id = X`. Si alcanza el límite, bloquea y muestra mensaje de upgrade.

---

## 11. API Endpoints

### 11.1 Sincronización
```
POST /api/v1/sync
```
Payload de sincronización batch de transacciones locales.

### 11.2 Reportes
```
GET /api/v1/business/{id}/reports?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
```
**Respuesta:**
```json
{
  "period": "2026-06-01 to 2026-06-05",
  "summary": {
    "total_sales": 15450.00,
    "total_expenses": 3200.00,
    "net_cash": 12250.00,
    "transaction_count": 84
  },
  "top_products": [
    {"name": "Tacos al Pastor", "quantity": 120},
    {"name": "Coca-Cola", "quantity": 45}
  ]
}
```

### 11.3 Auditoría
```
GET /api/v1/business/{id}/audit
```
Contenido:
- Lista de cancelaciones (con foto y motivo).
- Historial de arqueos de caja (diferencias detectadas).
- Alertas de "No registro": si el flujo del día es anormalmente bajo vs. promedio histórico → Push: *"Tus ventas están un 30% por debajo del promedio. ¿Todo bien en el punto de venta?"*

### 11.4 Planes y Precios
```
GET /api/v1/plans
```
Lista los planes disponibles con sus límites y precios.

```
GET /api/v1/business/{id}/license
```
Devuelve la licencia actual del negocio: plan, vencimiento, estado, uso actual vs límites.

```
POST /api/v1/business/{id}/license/upgrade
```
Inicia el proceso de upgrade (redirige a pasarela de pago o confirma upgrade directo).

```
POST /api/v1/business/{id}/license/cancel
```
Cancela la suscripción Premium (baja a Free al final del período).

**Respuesta de `GET /license`:**
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
  ],
  "payment": {
    "method": "stripe",
    "next_billing": "2026-07-01",
    "amount": 199.00,
    "currency": "MXN"
  }
}
```

### 11.5 Control de Materias Primas
```
POST /api/v1/business/{id}/stock-report
```
Registra el reporte diario de sobrantes del cajero.

```
GET /api/v1/business/{id}/purchase-suggestion?date=YYYY-MM-DD
```
Devuelve la sugerencia de pedido generada por la IA.

**Respuesta de sugerencia:**
```json
{
  "date_for": "2026-06-06",
  "reason": "Partido de fútbol a 2 km. Probabilidad de aumento de ventas: 75%.",
  "suggested_items": [
    {"supply": "Carne de res", "unit": "kg", "suggested_qty": 28, "current_stock": 2},
    {"supply": "Coca-Cola", "unit": "caja", "suggested_qty": 5, "current_stock": 1},
    {"supply": "Cebolla", "unit": "kg", "suggested_qty": 4, "current_stock": 0.5},
    {"supply": "Chorizo", "unit": "kg", "suggested_qty": 3, "current_stock": 0}
  ],
  "note": "Si no se vende todo hoy, los insumos no perecederos quedan para mañana."
}
```

---

## 12. Vigilancia del Patrón (Dashboard de Auditoría)

### 12.1 Pestaña "Auditoría"
1. **Bitácora de Cancelaciones:** Lista de cancelaciones por cajero, con motivo y foto de evidencia.
2. **Reporte por Cajero:** Comparativa de ventas (Juan vs. María) para detectar eficiencia o fraude.
3. **Comparativa de Tiempos:** Horas pico de venta. Dato clave para que la IA sugiera: *"Deberías tener 2 cajeros los viernes de 8pm a 10pm"*.

### 12.2 Flujo de Cancelación
1. Cajero pulsa "Cancelar".
2. Sistema verifica timestamp (< 3 min).
3. Cajero selecciona motivo y toma foto (obligatoria).
4. Backend dispara Push Notification al celular del Patrón: *"Cancelación detectada en [Negocio] - [Cajero]. Ver evidencia."*

---

## 13. Monetización y Estrategia de Conversión

### 13.1 Filosofía Free: "Que se enamore, pero que necesite más"

La versión Free debe ser **completamente funcional y útil** para un negocio pequeño — el dueño abre la app, registra ventas, ve su flujo de caja, da recibos por WhatsApp y activa el programa de lealtad. **Se enamora del sistema.**

Pero Free tiene **límites reales** que empujan la conversión cuando el negocio crece:
- **1 negocio solamente.** Si tienes 2 taquerías, necesitas Premium para agregar la segunda.
- **Máximo 2 cajeros.** Si contratas un tercer cajero, necesitas Premium.
- **Reportes básicos.** El reporte de estado del negocio solo muestra lo esencial. Para reportes detallados (por producto, por cajero, comparativas semanales), se necesita Premium.
- **Sin IA.** Los insights de IA personalizados, las proyecciones de flujo, la predicción de pedidos y las promociones inteligentes son Premium.
- **Control de materias primas.** El reporte de sobrantes es gratis, pero la predicción IA del pedido es Premium.

El mensaje implícito: *"Usa la app gratis todo lo que quieras. El día que quieras crecer, aquí está el plan para acompañarte."*

### 13.2 Modelo Freemium

| Característica | Free | Premium |
|----------------|------|---------|
| Control operativo (ventas, gastos, deudas) | ✅ | ✅ |
| Flujo de caja en tiempo real | ✅ | ✅ |
| Recibos WhatsApp + acumulación de puntos | ✅ | ✅ |
| Programa de lealtad (QR premios) | ✅ | ✅ |
| Reporte de sobrantes (materias primas) | ✅ | ✅ |
| Número de negocios | **1** | **Hasta 2** |
| Número de cajeros | **Máx. 2** | **Máx. 5** |
| Reporte básico del negocio | ✅ | ✅ |
| Reportes detallados (por cajero, producto, comparativas) | ❌ | ✅ |
| Predicción IA de pedido de materias primas | ❌ | ✅ |
| Insights IA personalizados | ❌ | ✅ |
| Promociones inteligentes (temporada baja) | ❌ | ✅ |
| Proyecciones de flujo | ❌ | ✅ |
| Alertas predictivas de quiebra | ❌ | ✅ |

### 13.3 Estrategia de Conversión (El "Efecto Juan Ramos")
- **El valor se entrega primero:** Control, claridad y lealtad son gratuitos. El negocio opera mejor que con libreta desde el día 1.
- **La monetización llega con el crecimiento:** No se bloquea nada esencial. Se cobra cuando el negocio necesita **más capacidad** (más sucursales, más cajeros, más inteligencia).
- **Upselling no bloqueante:** Banner de sugerencia en feed secundario con lenguaje aspiracional, nunca de bloqueo.

---

## 14. Roadmap de Implementación por Módulo

### Reportes (3 Fases)
1. **Fase 1 (MVP):** Reporte simple de Ingresos vs. Egresos por rango de fechas (endpoint JSON definido).
2. **Fase 2:** Filtro por "Cajero" + visualización de "Cancelaciones".
3. **Fase 3:** Integración con IA → botón: *"¿Quieres saber por qué vendiste menos el martes? (IA Premium)"*.

### Vigilancia y Auditoría (3 Fases)
1. **Fase 1:** Endpoint de auditoría básico con lista de cancelaciones.
2. **Fase 2:** Reporte por cajero y comparativa de tiempos.
3. **Fase 3:** Alertas predictivas de "No registro" vs. promedio histórico.

### Control de Materias Primas (3 Fases)
1. **Fase 1:** Reporte manual de sobrantes desde la app del cajero (listas predefinidas, captura rápida).
2. **Fase 2:** Algoritmo simple de sugerencia basado en: sobrantes × promedio histórico del mismo día de la semana.
3. **Fase 3:** IA completa con eventos externos (partidos, clima, temporada, festivos) + aprendizaje automático de patrones del negocio.

---

## 15. Consideraciones de Futuro (Escalabilidad)

La estructura técnica (Spring Boot + PostgreSQL) permite:

- **Escalabilidad a Grandes Administraciones:** El motor de datos puede migrar a sistemas robustos si el cliente madura.
- **Integración Bancaria Potencial:** Al tener datos de comportamiento financiero real y transaccional histórico, el sistema está posicionado para servir como "score" para micro-créditos de aliados financieros.
- **Ecosistema de Soluciones:** Si el sistema detecta flujo constante, la IA puede ofrecer soluciones de negocio (ej. proveedores aliados, recomendaciones de compra).

---

## 16. Arquitectura de Tenants (Resumen Técnico)

```
┌─────────────────────────────────────────┐
│            Taco'Os API                  │
│         (Spring Boot)                   │
├─────────────────────────────────────────┤
│  Middleware: Validación de Licencia     │
│  ─ Cada request lleva business_id       │
│  ─ Verifica plan y límites antes de     │
│    ejecutar la acción                   │
├─────────────────────────────────────────┤
│ business_id → License → ¿tiene permiso? │
├─────────────────────────────────────────┤
│  PostgreSQL: Todos los datos por        │
│  business_id (aislamiento lógico)       │
└─────────────────────────────────────────┘
```

- **Aislamiento:** Lógico por `business_id`, no físico (misma BD, mismas tablas).
- **Middleware:** Cada endpoint sensible a licencia pasa por un validador antes de ejecutar.
- **Escalabilidad:** Cuando un tenant crece, se le puede migrar a un cluster dedicado sin cambiar la app.

---

## 17. Estado del Proyecto y Prioridades

| Aspecto | Estado |
|---------|--------|
| Estrategia | ✅ Validada y alineada a necesidades reales del mercado |
| UX / Flujo | ✅ Definido (3 Botones, Onboarding, Roles) |
| Arquitectura | ✅ Definida (Offline-First, Spring Boot + PostgreSQL) |
| Modelo de Datos | ✅ Esquema esencial definido |
| API / Endpoints | ✅ Contratos definidos (/sync, /reports, /audit) |
| Monetización | ✅ Estrategia Freemium definida |
| **Prioridad Actual** | **Desarrollo del flujo local (Offline) + endpoint de sincronización masiva (/sync)** |

---

*Documento generado a partir de la consolidación de las versiones v1.1, v1.2 y v1.3 del TDD de Taco'Os.*
