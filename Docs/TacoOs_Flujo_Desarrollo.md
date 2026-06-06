# Flujo de Desarrollo — Proyecto Taco'Os

> **Equipo:**
> - **Jesus Medina** — Arquitecto / Backend (Spring Boot)
> - **Fanner** — Flutter + Backend
> - **Leandro** — Data Science

---

## Fase I — Control Operativo (MVP)

**Objetivo:** El sistema debe permitir registrar ventas, gastos y deudas desde el dispositivo del cajero, con o sin internet, y sincronizar cuando haya conexión.

### Criterios de Completitud (Definition of Done)
- [ ] Cajero puede registrarse con Google y elegir rol.
- [ ] Dueño puede crear un negocio y enlazar cajeros.
- [ ] Al crear un negocio, se genera automáticamente una **licencia Free** con sus límites.
- [ ] El backend valida límites de licencia al agregar cajeros (máx. 2 en Free).
- [ ] El backend valida límites de licencia al crear negocios (máx. 1 en Free).
- [ ] El dueño puede ver su licencia actual (plan, vencimiento, límites usados vs totales).
- [ ] Cajero puede registrar una venta con productos (existentes o creados al vuelo).
- [ ] Cajero puede registrar un gasto.
- [ ] Cajero puede registrar una deuda.
- [ ] La app funciona sin internet (SQLite local).
- [ ] Los datos se sincronizan automáticamente al detectar red.
- [ ] El dueño puede ver el flujo de caja en tiempo real.
- [ ] El dueño puede ver un reporte de ingresos vs egresos por rango de fechas.

### Validaciones de Licencia en Fase I
- `POST /business`: Si el dueño ya tiene 1 negocio en Free, bloquea con: *"Alcanzaste el límite de negocios. Mejora a Premium para agregar más."*
- `POST /auth/role` (cajero): Si el negocio ya tiene 2 cajeros en Free, bloquea con: *"Alcanzaste el límite de cajeros (máx. 2). Mejora a Premium."*
- La licencia Free se crea automáticamente al crear el negocio.
- No hay fecha de vencimiento para Free (es perpetuo).

### Asignación de Tareas

| Tarea | Responsable | Descripción |
|-------|-------------|-------------|
| **Backend — API** | Jesus | Endpoints REST: auth (JWT), CRUD negocios, CRUD productos, CRUD transacciones, sincronización batch (`POST /sync`), reportes (`GET /reports`). Base de datos PostgreSQL con esquema de Entidades Principales. **Sistema de licencias: tabla License, middleware de validación por plan, endpoints `GET /license`, `GET /plans`.** Seguridad: JWT 24h, logs inmutables. |
| **Backend — Sincronización** | Fanner + Jesus | Lógica de sincronización diferida. Job Scheduler, resolución de conflictos, validación de integridad (device_id, timestamp). |
| **Frontend — Flutter** | Fanner | UI de los 3 botones: "+ Venta", "- Gasto", "¿Cómo voy?". Pantalla de venta con selección de productos, Pop-up de cambio. Dashboard de flujo de caja. SQLite/Room local. Onboarding con Google Login y selección de rol. Configuración Just-in-Time. **Dashboard de licencia: plan actual, vencimiento, límites, botón de mejora.** |
| **Data Science** | Leandro | Definir estructura de datos para transacciones (items_json) que permita análisis futuro. Validar que el esquema local y el de la nube sean compatibles para ML. |

### Endpoints Clave
```
POST /api/v1/auth/login
POST /api/v1/business (crea negocio + licencia Free automática)
POST /api/v1/business/{id}/products
POST /api/v1/transactions
POST /api/v1/sync
GET  /api/v1/business/{id}/reports?start_date=&end_date=
GET  /api/v1/business/{id}/license (plan, vencimiento, límites)
GET  /api/v1/plans (planes disponibles)
```

---

## Fase II — Lealtad, Anti-Fraude y CRM WhatsApp

**Objetivo:** El sistema debe eliminar el fraude del cajero mediante presión social (cliente exige recibo para acumular puntos), fidelizar clientes con recompensas, y capturar datos de consumo.

### Criterios de Completitud
- [ ] Cliente puede registrarse con su número de teléfono al pagar.
- [ ] Al cerrar venta con cliente registrado, se envía recibo por WhatsApp.
- [ ] El recibo incluye el mensaje de recompensa acumulada y QR si aplica.
- [ ] El sistema acumula compras por cliente y dispara premio al alcanzar el umbral.
- [ ] El premio se canjea mediante código QR escaneable desde la app del cajero.
- [ ] El dueño puede configurar el programa de lealtad (umbral, premio).
- [ ] Cancelación con foto de evidencia + push al dueño (ventana de 3 min).
- [ ] Si el cliente no está registrado, la venta se registra con folio genérico (modo inicial).

### Asignación de Tareas

| Tarea | Responsable | Descripción |
|-------|-------------|-------------|
| **WhatsApp API** | Jesus | Integración con API de WhatsApp Business para envío de recibos. Plantillas de mensajes aprobadas. Gestión de límites y costos. |
| **Backend — Lealtad** | Jesus | CRUD de programa de lealtad, acumulación de puntos, generación de QR para premios, validación de canje. Entidades: LoyaltyProgram, CustomerPoints, RewardRedemption. |
| **Backend — Anti-Fraude** | Fanner | Lógica de cancelación con ventana de 3 min, almacenamiento de fotos (base64/URL), push notifications al dueño. |
| **Frontend — Flutter** | Fanner | Pantalla de venta con campo opcional de cliente. Vista de recibo WhatsApp. Escáner de QR para canje de premios. Flujo de cancelación con captura de foto. |
| **Data Science** | Leandro | Diseñar el modelo de datos de customer behavior. Definir qué métricas de lealtad capturar para análisis futuro (frecuencia, ticket promedio, productos favoritos). |

### Ejemplo de Recibo WhatsApp
```
Taquería Bonita
25 Tacos · 2 Cocas = $355
¡Gracias por cenar con nosotros!
🎉 Tienes 1 taco gratis en tu próxima visita
→ Código QR adjunto
```

### Endpoints Clave
```
POST /api/v1/business/{id}/loyalty-program
POST /api/v1/customers
POST /api/v1/transactions (con customer_phone opcional)
GET  /api/v1/rewards/{customer_id}/current
POST /api/v1/rewards/{id}/redeem (escanea QR)
POST /api/v1/transactions/{id}/cancel
```

---

## Fase III — Inteligencia Artificial y Reportes Avanzados

**Objetivo:** El sistema debe analizar los datos consolidados para generar insights personalizados, proyecciones de flujo, alertas de quiebra, y estrategias de negocio.

### Criterios de Completitud
- [ ] El motor de IA procesa datos en batch (no en tiempo real).
- [ ] Free: 1 insight genérico de comunidad por semana.
- [ ] Premium: Insights personalizados diarios.
- [ ] Premium: Proyecciones de flujo de caja a 7/30 días.
- [ ] Premium: Alerta temprana de riesgo de quiebra.
- [ ] Premium: Análisis de lealtad (clientes frecuentes, pérdida).
- [ ] Premium: Recomendación de estrategia de compras.
- [ ] El banner de upgrade aparece en "¿Cómo voy?" con lenguaje aspiracional.
- [ ] Reportes detallados: por cajero, por producto, por hora, comparativas semanales.
- [ ] **Sistema de upgrades funcional:** El dueño puede ver planes, elegir Premium, pagar, y recibir la licencia actualizada al instante.
- [ ] **Vencimiento automático:** Si un Premium vence, el sistema lo baja a Free sin perder datos.
- [ ] **Dashboard de licencia:** El dueño ve su plan, días restantes (si aplica), límites usados vs totales.

### Asignación de Tareas

| Tarea | Responsable | Descripción |
|-------|-------------|-------------|
| **Backend — Reportes** | Jesus | Endpoints de reportes detallados (`GET /reports` con filtros por cajero, producto, hora). Endpoint de auditoría (`GET /audit`). Alertas de "No registro" (comparativa vs promedio histórico). |
| **Backend — Licencias y Pagos** | Jesus | CRUD de planes (`GET /plans`). Upgrade de licencia (`POST /license/upgrade`). Vencimiento automático (batch nocturno que baja a Free). Integración con pasarela de pago (Stripe). Webhook para confirmar pagos. |
| **Backend — Batch Processing** | Fanner | Infraestructura de batch jobs (Spring Batch o similar). Programación de ejecución diaria/nocturna. Pipeline de datos desde PostgreSQL hacia el motor de IA. |
| **Data Science — Modelos** | Leandro | Modelo de predicción de flujo de caja. Algoritmo de alerta temprana de quiebra (basado en capacidad de pago vs ingresos). Clasificador de insights (qué decir y cuándo). Sistema de recomendación de estrategia de compras. Segmentación de clientes por lealtad. |
| **Data Science — Insights Genéricos** | Leandro | Generar insights de comunidad: promedios del sector, tendencias, comparativas anónimas. "Negocios como el tuyo aumentaron sus ventas 15% este mes usando..." |
| **Frontend — Flutter** | Fanner | Vista de "¿Cómo voy?" con indicadores de salud (verde/ámbar/rojo). Banner de upgrade no intrusivo al final de la pantalla. Reportes detallados con gráficos simples. **Dashboard de licencia: plan, vencimiento, barras de uso (cajeros usados/total). Botón de mejora que redirige a planes.** |

### Endpoints Clave
```
GET  /api/v1/business/{id}/insights (diario o semanal según plan)
GET  /api/v1/business/{id}/cashflow-projection
GET  /api/v1/business/{id}/audit
GET  /api/v1/business/{id}/reports?filter=cashier&value=123
POST /api/v1/business/{id}/alerts/config
```

---

## Fase IV — Digitalización QR (Menú Interactivo)

**Objetivo:** Digitalizar la experiencia del comensal con menú QR en mesa y gestión de inventario en tiempo real.

### Criterios de Completitud
- [ ] El dueño puede generar un menú digital desde los productos registrados.
- [ ] Se genera un código QR único por mesa o por negocio.
- [ ] El cliente escanea el QR y ve el menú en su celular.
- [ ] El cliente puede hacer su pedido desde el menú QR.
- [ ] El pedido llega a la pantalla del cajero.
- [ ] El cajero confirma el pedido y se registra como venta.
- [ ] El inventario de productos se descuenta en tiempo real.
- [ ] El dueño recibe alerta de stock bajo.

### Asignación de Tareas

| Tarea | Responsable | Descripción |
|-------|-------------|-------------|
| **Backend — Menú QR** | Jesus | Endpoints para generar y servir menú digital. Asociación QR → negocio/mesa. Gestión de pedidos entrantes. |
| **Backend — Inventario** | Jesus + Fanner | Lógica de descuento de inventario al registrar venta. Alertas de stock bajo (push al dueño). Umbrales configurables. |
| **Frontend — Flutter** | Fanner | Interfaz del cajero para ver pedidos entrantes (cola de órdenes). Pantalla de confirmación de pedido. Alertas de stock. |
| **Frontend — Web/Móvil Cliente** | Fanner | Página web liviana o vista embebida del menú que ve el cliente al escanear el QR. Selección de productos y envío de pedido. Sin necesidad de login para el cliente. |
| **Data Science** | Leandro | Análisis de datos de pedidos: productos más pedidos por mesa, hora, día. Correlación con clima/eventos. |

---

## Fase V — Control de Materias Primas (Abasto Inteligente)

**Objetivo:** El sistema debe ayudar al dueño a saber exactamente qué comprar en el mercado cada mañana, reduciendo merma y evitando faltantes.

### Criterios de Completitud
- [ ] El dueño configura la lista de insumos del negocio una vez.
- [ ] Al cierre del día, el cajero reporta los sobrantes en menos de 2 minutos.
- [ ] El sistema guarda el historial de sobrantes por día.
- [ ] La IA genera una sugerencia de pedido basada en: sobrantes + historial de ventas + día de la semana.
- [ ] La IA considera eventos externos (partidos, festivos, temporada) si el dueño los marca.
- [ ] La sugerencia llega al dueño como notificación o al abrir la app.
- [ ] El dueño puede ajustar cantidades y confirmar.
- [ ] El sistema puede exportar la lista de compras.

### Asignación de Tareas

| Tarea | Responsable | Descripción |
|-------|-------------|-------------|
| **Backend — Stock Reports** | Jesus | CRUD de insumos (Supply). Endpoint para reporte diario de sobrantes (`POST /stock-report`). Endpoint para sugerencia de pedido (`GET /purchase-suggestion`). Histórico de consumos. |
| **Frontend — Flutter** | Fanner | Pantalla de reporte rápido de sobrantes al cierre del turno (listas predefinidas, entrada numérica). Vista para el dueño con la sugerencia de pedido y opción de ajuste. |
| **Data Science — Predicción** | Leandro | Modelo de predicción de demanda de insumos. Variables: ventas históricas del producto, día de la semana, estacionalidad, eventos externos (input del dueño o scraping de calendarios). Algoritmo que recomienda cantidades con mensaje explicativo ("Compra 40% extra porque..."). |
| **Data Science — Eventos** | Leandro | Sistema de marcado de eventos (partido, festival, lluvia). El dueño puede marcar eventos manualmente al inicio. A futuro: integrar APIs de clima y calendarios deportivos/festivos. |

### Ejemplo de Flujo
```
🌙 Cierre (Cajero):
"Reporta sobrantes → 2 cajas Coca, 20 kg carne, 1 kg cebolla"

🤖 IA procesa:
"Partido de fútbol a 2 km mañana. Probabilidad 75% de aumento."

☀️ Mañana (Dueño abre app):
"📋 Sugerencia de pedido: 40% extra de carne y refrescos.
   Si no se vende hoy, tienes para mañana.
   ¿Confirmar? [Sí] [Ajustar]"
```

### Endpoints Clave
```
GET  /api/v1/business/{id}/supplies
POST /api/v1/business/{id}/stock-report
GET  /api/v1/business/{id}/purchase-suggestion?date=YYYY-MM-DD
POST /api/v1/business/{id}/purchase-suggestion/{id}/confirm
POST /api/v1/business/{id}/events (marcar partido, festival, etc.)
```

---

## Resumen de Responsabilidades por Fase

| Fase | Jesus Medina (Backend) | Fanner (Flutter + Backend) | Leandro (Data Science) |
|------|----------------------|---------------------------|----------------------|
| **I — Control Operativo** | API REST, Auth JWT, PostgreSQL, Sync, Reportes básicos, **Sistema de licencias (tabla License, middleware, validaciones por plan)** | UI 3 botones, Offline-first SQLite, Onboarding, Flujo de venta, **Dashboard de licencia (plan, límites usados)** | Validar esquema de datos para ML futuro |
| **II — Lealtad y Anti-Fraude** | WhatsApp API, Lealtad CRUD, QR rewards, Push notifications | Campo cliente en venta, Recibo WhatsApp, Escáner QR, Cancelación con foto | Modelo customer behavior, métricas de lealtad |
| **III — IA y Reportes** | Reportes detallados, Auditoría, Alertas "No registro", **API de Planes (GET /plans), Upgrade de licencia (POST /upgrade), Vencimiento automático** | Infraestructura Batch, Vista "¿Cómo voy?", Banner upgrade, **Dashboard de licencia con upgrade** | Modelos: proyección flujo, alerta quiebra, insights, segmentación |
| **IV — QR Digital** | Menú QR API, Gestión de pedidos, Inventario | Cola de pedidos, UI menú cliente (web), Alertas stock bajo | Análisis de pedidos por mesa/hora/día |
| **V — Materias Primas** | CRUD insumos, Stock report endpoint, Purchase suggestion API | UI reporte sobrantes, Vista sugerencia pedido, Ajuste de cantidades | Predicción demanda insumos, Sistema de eventos externos |

---

## Notas Técnicas para el Equipo

### Jesus — Backend (Spring Boot)
- Prioridad: definir esquema PostgreSQL y endpoints de sincronización primero.
- JWT con 24h de expiración, almacenado en SecureStorage del lado Flutter.
- Todos los logs de transacciones son inmutables (no DELETE, solo status = cancelled).
- La foto del baucher (pago tarjeta) se almacena como referencia, no hay integración bancaria.
- **Arquitectura de tenants:** Toda consulta lleva `business_id`. Middleware de licencia valida límites antes de cada operación que los afecte.
- **Middleware de licencia:** `validateLicense(business_id, action)` → verifica plan, vencimiento, y conteo actual vs límite antes de ejecutar. Si excede, responde con error `license_limit_reached`.

### Fanner — Flutter + Backend
- La app debe funcionar 100% offline. SQLite/Room es la base de datos maestra local.
- Sincronización en segundo plano cada 5-10 min o al detectar red.
- Los 3 botones deben ser el centro de la UX. No agregar opciones innecesarias.
- El QR de premio se genera como imagen desde el backend y se envía incrustado en el mensaje WhatsApp.
- **Dashboard de licencia:** El dueño debe poder ver su plan actual, cuántos cajeros lleva usados vs su límite, y si tiene fecha de vencimiento. Cuando esté cerca de vencer (< 15 días), mostrar alerta amarilla. Cuando venza, mostrar alerta roja.

### Leandro — Data Science
- Los modelos de IA son batch, no en tiempo real. Se ejecutan diariamente (procesamiento nocturno).
- Datos mínimos para entrenar: 30 días de transacciones consistentes.
- Los insights genéricos de comunidad se generan con datos agregados de todos los negocios (anonimizados).
- La predicción de materias primas arranca con reglas simples (promedio histórico + día semana) y evoluciona a ML.
- **Datos de licencia:** El plan del negocio (free/premium) es una variable para los modelos. Los insights premium solo se generan si `plan = premium`.
