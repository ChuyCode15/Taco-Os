# Flujo de Desarrollo — Proyecto Taco'Os (Fase I)

> **Equipo:**
> - **Jesus Medina** — Arquitecto / Backend (Spring Boot)
> - **Fanner** — Flutter + Backend
> - **Leandro** — Data Science

---

## Fase I — Control Operativo (MVP)

**Objetivo:** El sistema debe permitir registrar ventas y gastos desde el dispositivo del cajero, con o sin internet, gestionar cortes de caja, y sincronizar datos cada 5 minutos. Sin CRM, sin WhatsApp, sin IA.

---

### Criterios de Completitud (Definition of Done)

#### Onboarding y Roles
- [ ] Usuario puede iniciar sesión con Google Sign-In.
- [ ] Al ser primera vez, el backend crea el usuario automáticamente.
- [ ] Usuario elige rol: Dueño o Cajero.
- [ ] Si elige Cajero, la app bloquea la pantalla y abre la cámara QR automáticamente.
- [ ] Cajero escanea QR de invitación del Patrón y queda enlazado al negocio.
- [ ] Al enlazar, el backend valida que no se exceda el límite de cajeros del plan.

#### Dashboard Patrón (3+1+1+🔔)
- [ ] Dashboard con 3 botones principales: Ventas, Reportes, Equipo.
- [ ] **Ventas**: Toggle a Modo Cajero para cobrar directamente.
- [ ] **Reportes**: 3 subsecciones (Cajas Abiertas, Cortes, Estadísticas).
- [ ] **Equipo**: Lista de cajeros, generar QR, desvincular con seguridad.
- [ ] **⚙️**: Acceso a Productos, Sucursales, Mi Plan.
- [ ] **☰**: Perfil, Dark Mode, Ayuda.
- [ ] **🔔**: Campanita con contador de notificaciones no leídas.

#### Apertura de Caja (Modo Cajero)
- [ ] Botón "Abrir Caja" con campo para fondo de cambio.
- [ ] Al confirmar, se crea una sesión de caja local y remota.

#### Catálogo de Productos
- [ ] 3 categorías fijas: Comida, Bebidas, Postres.
- [ ] Al seleccionar una categoría, se muestra la lista de productos.
- [ ] Popup con nombre del producto, caja de cantidad y teclado numérico de 9 dígitos.
- [ ] Producto se agrega a la lista de venta actual y se suma al total.

#### Productos al Vuelo
- [ ] Si una categoría está vacía, botón "Registrar Producto".
- [ ] Popup: nombre, precio, categoría, foto opcional.
- [ ] Solo disponible si el Cajero tiene permiso del Patrón (campo permissions en User).

#### Pago
- [ ] Botón "Cobrar" → dos opciones: Efectivo o Tarjeta.
- [ ] **Efectivo**: Cajero ingresa monto recibido, app calcula cambio. Se registra venta.
- [ ] **Tarjeta**: Se abre cámara para foto del baucher. Se registra venta (no afecta efectivo).

#### Footer del Cajero
- [ ] 3 botones fijos: [Ventas] [Gastos] [¿Cómo voy?].
- [ ] **Ventas**: Registra una nueva venta (acción principal).
- [ ] **Gastos**: Popup con cantidad, detalle, ¿para qué?, ¿quién?.
- [ ] **¿Cómo voy?**: Vista previa al corte con totales del turno.

#### Corte Manual
- [ ] Confirmación antes de generar corte.
- [ ] Resumen automático: ventas, efectivo, tarjeta, gastos, fondo.
- [ ] Cajero ingresa conteo manual del efectivo físico.
- [ ] Sistema calcula diferencia (sobrante/faltante) y genera registro.
- [ ] Ticket digital imprimible/compartible.
- [ ] Al finalizar, vuelve a pantalla de "Abrir Caja".
- [ ] Corte no cierra sesión del usuario.

#### Auto-cierre
- [ ] Hora de cierre configurable al registrar el negocio (opcional).
- [ ] Si hay caja abierta a hora config + 180 min → cierre automático.
- [ ] Se genera reporte de auto-cierre y 🔔 al Patrón.

#### Cancelación (Anti-Fraude)
- [ ] Ventana de 5 minutos para cancelar desde el timestamp de la venta.
- [ ] Selección de causa obligatoria.
- [ ] Foto del producto devuelto obligatoria.
- [ ] Notificación 🔔 inmediata al Patrón.
- [ ] Log inmutable: la venta original no se borra, solo cambia status.

#### Autenticación y Sesión
- [ ] JWT con sesión larga (todo el turno).
- [ ] Si app en segundo plano > 12 horas → requiere re-login.
- [ ] SecureStorage en Flutter.
- [ ] Cerrar sesión manual desde ☰.

#### Offline-First y Sincronización
- [ ] App funciona 100% sin internet (SQLite local como base maestra).
- [ ] Todas las transacciones, sesiones, productos y cortes se guardan localmente primero.
- [ ] Worker en segundo plano sincroniza cada 5 minutos.
- [ ] Resolución de conflictos: gana timestamp más reciente.
- [ ] Logs inmutables en el backend.

#### Licencias
- [ ] Free: 1 negocio, 2 cajeros, sin IA.
- [ ] Premium: 2 negocios, 5 cajeros, sin IA (trial 14 días disponible).
- [ ] Business: 5 negocios, 25 empleados, IA completa (trial 14 días disponible).
- [ ] Validación de límites al generar QR de invitación y al crear negocio.
- [ ] Dashboard de licencia con plan actual, límites usados vs totales.
- [ ] Si expira trial, baja automáticamente a Free sin pérdida de datos.

#### Reportes del Patrón
- [ ] **Cajas Abiertas**: Lista de cajas activas con resumen (transacciones, ventas, gastos).
- [ ] **Lista de Cortes**: Historial con filtros por sucursal, cajero, fecha.
- [ ] **Estadísticas**: Comparativa mejor semana vs semana activa.

---

### Asignación de Tareas por Sección

| Sec | Tarea | Responsable | Descripción |
|-----|-------|-------------|-------------|
| **8** | Auth Google + JWT | Jesús | Endpoint `POST /auth/login`, `PUT /auth/role`. JWT con sesión larga, expira 12hr en 2do plano. SecureStorage. |
| **12** | QR Invitación + Enlace | Jesús + Fanner | `POST /invitation` (generar QR), `POST /link-cashier` (enlazar). Validar límites de licencia. Flutter: abrir cámara al seleccionar cajero. |
| **12.3** | CRUD Cajeros | Jesús | `GET /business/{id}/cashiers`, `DELETE /business/{id}/cashiers/{id}` con confirmación. |
| **5.2** | CRUD Productos | Jesús + Fanner | `GET/POST/PUT/DELETE /products`. Categorías fijas: comida, bebidas, postres. |
| **5.1** | Apertura de Caja | Jesús + Fanner | `POST /cashier/open-session`. Flutter: popup con fondo de cambio. |
| **5.5 - 5.6** | Transacciones | Jesús + Fanner | `POST /transactions` con payment method (cash/card). Flutter: flujo de cobro + cámara para baucher. |
| **5.7** | Footer Cajero | Fanner | 3 botones fijos en UI. Popup de gastos. Vista previa "¿Cómo voy?". |
| **6** | Corte Manual | Jesús + Fanner | `POST /cashier/close-session`. Flutter: confirmación → resumen → conteo → ticket. |
| **6.2** | Auto-cierre | Jesús | Job schedulado que verifica cajas abiertas vs hora config + 180 min. Genera 🔔. |
| **7** | Cancelación | Jesús + Fanner | `POST /transactions/{id}/cancel`. Validar 5 min. Flutter: selección de causa + cámara. 🔔 al Patrón. |
| **10** | Sync Batch | Fanner + Jesús | Worker cada 5 min. `POST /sync`. Resolución de conflictos. |
| **4.2** | Reportes | Jesús | `GET /reports/open-sessions`, `GET /reports/cuts` (con filtros), `GET /reports/stats`. |
| **4.6** | Notificaciones | Jesús | `GET /notifications`, `DELETE /notifications/{id}`. Tipos: cancelación, diferencia, auto-cierre. |
| **3.3** | Licencias | Jesús | `GET /plans`, `GET /license`, `POST /upgrade`, `POST /trial`. Middleware de validación. |
| **9** | Modelo de Datos | Jesús + Leandro | Definir esquemas SQLite y PostgreSQL. Entidades: Business, User, Session, Transaction, Product, Cut, Notification, License. |
| **4** | UI Dashboard Patrón | Fanner | Layout 3+1+1+🔔. Componentes: botones, engrane, hamburger, campanita. |
| **5** | UI Modo Cajero | Fanner | Pantalla de cobro, catálogo, teclado numérico, footer. |
| **11** | Permisos Cajero | Jesús + Fanner | Campo `permissions` en User (JSON). Validar al crear/editar/eliminar productos. Toggle en UI de registro. |

---

### Endpoints Clave por Sección

```
Sec 8:  POST   /api/v1/auth/login
Sec 8:  PUT    /api/v1/auth/role

Sec 12: POST   /api/v1/business/{id}/cashiers/invitation
Sec 12: POST   /api/v1/business/link-cashier
Sec 12: GET    /api/v1/business/{id}/cashiers
Sec 12: DELETE /api/v1/business/{id}/cashiers/{id}

Sec 5.1: POST  /api/v1/cashier/open-session

Sec 5.2: GET   /api/v1/business/{id}/products?category=
Sec 5.2: POST  /api/v1/business/{id}/products
Sec 5.2: PUT   /api/v1/business/{id}/products/{id}
Sec 5.2: DELETE /api/v1/business/{id}/products/{id}

Sec 5.5: POST  /api/v1/transactions (venta efectivo)
Sec 5.6: POST  /api/v1/transactions (venta tarjeta)
Sec 5.7: POST  /api/v1/transactions (gasto)

Sec 6:   POST  /api/v1/cashier/close-session

Sec 7:   POST  /api/v1/transactions/{id}/cancel

Sec 10:  POST  /api/v1/sync

Sec 4.2: GET   /api/v1/business/{id}/reports/open-sessions
Sec 4.2: GET   /api/v1/business/{id}/reports/cuts?branch=&cashier_id=&dates=
Sec 4.2: GET   /api/v1/business/{id}/reports/stats

Sec 4.6: GET   /api/v1/business/{id}/notifications
Sec 4.6: DELETE /api/v1/business/{id}/notifications/{id}

Sec 3.3: GET   /api/v1/plans
Sec 3.3: GET   /api/v1/business/{id}/license
Sec 3.3: POST  /api/v1/business/{id}/license/upgrade
Sec 3.3: POST  /api/v1/business/{id}/license/trial
```

---

### Resumen de Responsabilidades

| Área | Jesus (Backend) | Fanner (Flutter + Backend) | Leandro (Data Science) |
|------|----------------|---------------------------|----------------------|
| Auth + Sesión | Endpoints JWT, Google Sign-In | SecureStorage, manejo de sesión | — |
| Onboarding QR | Invitación, enlace, validación licencia | Cámara QR, UI onboarding | — |
| Catálogo | CRUD productos, categorías fijas | Lista, popup, teclado numérico | Validar esquema items_json |
| Transacciones | Endpoint universal, validación 5 min | Flujo cobro, cámara baucher | — |
| Corte | Apertura/cierre sesión, auto-cierre | UI corte, conteo, ticket | — |
| Sync | Batch endpoint, resolución conflictos | Worker 5 min, SQLite local | Compatibilidad esquemas |
| Reportes | Cajas abiertas, cortes, estadísticas | UI reportes, filtros, gráficas | — |
| Notificaciones | CRUD, tipos, push | Campanita 🔔, historial | — |
| Licencias | Planes, trial, middleware validación | UI dashboard licencia, upsell | — |
| Permisos | Campo permissions, validación backend | Toggle permisos en registro cajero | — |

---

### Notas Técnicas para el Equipo

**Jesus — Backend (Spring Boot):**
- Prioridad: esquema PostgreSQL, endpoints de sincronización y corte.
- JWT con sesión larga (turno). 12hr en segundo plano → expira.
- Middleware de licencia: `validateLicense(business_id, action)` verifica plan y límites antes de ejecutar.
- Logs inmutables: no DELETE, solo status = cancelled o status = deleted (soft delete).
- Auto-cierre: job schedulado que verifica `business.closing_time + 180 min` contra `session.opened_at`.

**Fanner — Flutter:**
- App 100% offline. SQLite es la base maestra local.
- Sincronización worker cada 5 min.
- Teclado numérico de 9 dígitos como widget reutilizable.
- Cámara QR se abre automáticamente al seleccionar rol Cajero.
- Footer de 3 botones fijo en la parte inferior del Modo Cajero.

**Leandro — Data Science:**
- Los modelos de IA son batch y comienzan después de Fase I.
- Definir estructura de `items_json` que permita análisis futuro.
- Los datos de licencia y permisos deben ser compatibles con ML futuro.
- Validar que el esquema local (SQLite) y el de la nube (PostgreSQL) sean compatibles.
