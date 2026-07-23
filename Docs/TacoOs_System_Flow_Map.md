# System Flow Map — Taco'Os (Fase I)

> **Mapa completo del flujo del sistema.**  
> Cada flecha representa una acción del usuario o del sistema.  
> Cada `[endpoint]` es un contrato API.

---

## 1. Onboarding y Enlace (Registro Inicial)

```
[USUARIO NUEVO]
      │
      ▼
┌─────────────────────┐
│  Google Sign-In     │
│  POST /auth/login   │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Elegir Rol         │
│  PUT /auth/role     │
└─────────┬───────────┘
          │
     ┌────┴────┐
     ▼         ▼
[DUEÑO]    [CAJERO]
  │           │
  │           ▼
  │    ┌──────────────────┐
  │    │  Cámara QR se    │
  │    │  abre automática │
  │    └────────┬─────────┘
  │             │
  │             ▼
  │    ┌──────────────────┐
  │    │  Escanea QR de   │
  │    │  invitación      │
  │    └────────┬─────────┘
  │             │
  ▼             ▼
┌──────────────────────┐      ┌─────────────────────────┐
│  Crear Negocio       │      │  POST /link-cashier     │
│  POST /business      │◄────>│  Intercambio de datos:  │
│  ─ Nombre            │      │  Cajero → nombre, email │
│  ─ Ubicación         │      │          teléfono, ID   │
│  ─ Horario cierre    │      │  Backend → negocio,     │
│  (opcional)          │      │            dueño         │
│  ─ Licencia Free     │      └──────────┬──────────────┘
│    automática        │                 │
└──────────┬───────────┘                 │
           │                             │
           └──────────┬──────────────────┘
                      ▼
         ┌─────────────────────────┐
         │  Usuario listo para     │
         │  operar                 │
         │  Cajero → Pantalla venta│
         │  Dueño  → Dashboard     │
         └─────────────────────────┘
```

---

## 2. Dashboard del Patrón (Dueño)

```
┌──────────────────────────────────────────────────┐
│              DASHBOARD PATRÓN                     │
│  ┌──────┐  ┌────────┐  ┌──────┐  ⚙️  ☰   🔔   │
│  │VENTAS│  │REPORTES│  │EQUIPO│                  │
│  └──┬───┘  └───┬────┘  └──┬───┘                  │
│     │          │          │                       │
└─────┼──────────┼──────────┼───────────────────────┘
      │          │          │
      ▼          ▼          ▼
┌─────────┐ ┌──────────┐ ┌──────────────────┐
│TOGGLE A │ │Cajas     │ │Lista de cajeros  │
│MODO     │ │Abiertas  │ │[+] Registrar     │
│CAJERO   │ │  ─ lista │ │    nuevo (QR)    │
│         │ │  ─ resum │ │[−] Desvincular   │
│         │ │Cortes    │ │    (seguridad)    │
│         │ │  ─ filtri│ │Permisos:         │
│         │ │Estadíst. │ │  productos:      │
│         │ │  ─ mejor │ │  ☑ crear         │
│         │ │    semana│ │  ☑ editar        │
│         │ │  ─ activa│ │  ☑ eliminar      │
└─────────┘ └──────────┘ └──────────────────┘
```

---

## 3. Modo Cajero (Dueño o Cajero Empleado)

### 3.1 Apertura de Caja

```
[INICIO TURNO]
      │
      ▼
┌──────────────────────┐
│  Botón "Abrir Caja"  │
└─────────┬────────────┘
          │
          ▼
┌──────────────────────┐
│  Popup: "Fondo de    │
│  cambio: $___"       │
└─────────┬────────────┘
          │
          ▼
┌──────────────────────┐
│  POST /open-session  │
│  ← session_id        │
└─────────┬────────────┘
          │
          ▼
┌──────────────────────┐
│  Pantalla de cobro   │
│  activa              │
└──────────────────────┘
```

### 3.2 Ciclo de Cobro

```
[CAJA ABIERTA - PANTALLA DE COBRO]
      │
      ▼
┌─────────────────────────────────────────┐
│  Body: Lista de productos agregados     │
│  + Total grande abajo: $0.00           │
│  + Botón [+ Agregar Producto]          │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  Catálogo de 3 categorías fijas:        │
│  [COMIDA] [BEBIDAS] [POSTRES]          │
│  (default: comida)                      │
└──────────────────┬──────────────────────┘
                   │
         ┌─────────┴────────────┐
         ▼                      ▼
   [HAY PRODUCTOS]        [NO HAY PRODUCTOS]
         │                      │
         ▼                      ▼
┌──────────────────┐  ┌──────────────────────┐
│  Selecciona      │  │  Botón "Registrar    │
│  producto        │  │  Producto"           │
└────────┬─────────┘  │  ─ nombre            │
         │            │  ─ precio            │
         ▼            │  ─ categoría         │
┌──────────────────┐  │  ─ foto (opcional)   │
│  Popup:          │  │  POST /products      │
│  ─ producto      │  └──────────┬───────────┘
│  ─ cantidad [9]  │             │
│  ─ teclado       │             ▼
│    numérico      │      (vuelve al catálogo)
│  [ACEPTAR]       │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Producto agregado a lista.             │
│  Total actualizado.                     │
│  Botón [+ Agregar otro]                │
│  Botón [COBRAR]                         │
└──────────────────┬──────────────────────┘
                   │
                   ▼
          ┌────────────────┐
          │  Clic [COBRAR] │
          └───────┬────────┘
                  │
                  ▼
         ┌───────────────────┐
         │  Total: $XXX      │
         │  [EFECTIVO]       │
         │  [TARJETA]        │
         └────────┬──────────┘
                  │
            ┌─────┴──────┐
            ▼            ▼
    ┌────────────┐ ┌──────────────────┐
    │ EFECTIVO   │ │ TARJETA          │
    │ ¿Con       │ │ Abre cámara      │
    │ cuánto     │ │ para foto del    │
    │ paga?     │ │ baucher          │
    │ $___      │ │                  │
    │            │ │ POST /transact.  │
    │ POST       │ │ payment.card     │
    │ /transact. │ │ ← status: COMPL  │
    │ payment.   │ └────────┬─────────┘
    │ cash       │          │
    │ ← cambio:  │          │
    │   $XXX     │          │
    └─────┬──────┘          │
          │                 │
          └──────┬──────────┘
                 ▼
        ┌──────────────────┐
        │  POST /sync      │
        │  (en background  │
        │   cada 5 min)    │
        │                  │
        │  Vuelve a        │
        │  pantalla de     │
        │  cobro vacía     │
        └──────────────────┘
```

### 3.3 Cancelación

```
[DENTRO DE PANTALLA DE COBRO]
      │
      ▼
┌──────────────────────────────┐
│  Cajero selecciona venta     │
│  de la lista del día         │
│  → "Cancelar"               │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  ¿Menos de 5 minutos?       │
│  ─ NO → Bloqueado           │
│  ─ SÍ → Continúa            │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  Selecciona motivo:         │
│  ─ cliente_se_arrepintio    │
│  ─ producto_equivocado      │
│  ─ error_cajero             │
│  ─ otro                     │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  Toma foto del producto      │
│  devuelto (obligatoria)      │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  POST /transactions/{id}/   │
│       cancel                │
│  → Transaction.status:      │
│    COMPLETED → CANCELLED    │
│  → Se crea registro en      │
│    cancellations (foto +    │
│    motivo)                  │
│  → 🔔 al Patrón             │
│  → Log inmutable, no se     │
│    borra el registro        │
└──────────────────────────────┘
```

---

## 4. Footer del Cajero

```
┌──────────────────────────────────────────────────────┐
│  FOOTER (fijo en la parte inferior)                   │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐ │
│  │ [VENTAS] │  │ [GASTOS] │  │ [¿CÓMO VOY?]       │ │
│  │ Nueva    │  │ Popup:   │  │ Vista previa al    │ │
│  │ venta    │  │ cantidad │  │ corte:             │ │
│  │          │  │ detalle  │  │ ─ ventas totales   │ │
│  │          │  │ ¿para    │  │ ─ gastos           │ │
│  │          │  │ qué?     │  │ ─ métodos de pago  │ │
│  │          │  │ ¿quién?  │  └────────────────────┘ │
│  └──────────┘  └──────────┘                          │
└──────────────────────────────────────────────────────┘
```

---

## 5. Corte de Caja

```
[Cajero da clic en ¿CÓMO VOY? o en CORTE (al final)]
      │
      ▼
┌──────────────────────────────┐
│  Confirmación:               │
│  "¿Generar corte?"           │
│  [OK] [Cancelar]             │
└─────────────┬────────────────┘
              │ (OK)
              ▼
┌──────────────────────────────┐
│  Resumen automático:         │
│  ─ Ventas totales: $7,000   │
│  ─ Efectivo: $4,500         │
│  ─ Tarjeta: $2,500          │
│  ─ Gastos: $1,500           │
│  ─ Fondo de caja: $500      │
│  ─ Efectivo esperado: $3,500│
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  Conteo manual:              │
│  "¿Cuánto dinero hay en      │
│   caja?"                     │
│  Cajero ingresa monto físico │
│  → $_______                  │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  POST /cashier/close-session │
│  { actual_cash: 3500.00 }   │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────────────┐
│  Cálculo: expected_cash - actual     │
│  ─ 0     → Corte OK                  │
│  ─ >0    → Sobrante (🔔 al Patrón)  │
│  ─ <0    → Faltante (🔔 al Patrón)  │
└─────────────┬────────────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  Ticket digital:             │
│  PDF imprimible/compartible  │
│  ─ Hora apertura             │
│  ─ Hora cierre               │
│  ─ Resumen económico         │
│  ─ Diferencia                │
│                              │
│  [COMPARTIR] [GUARDAR]       │
└─────────────┬────────────────┘
              │
              ▼
┌──────────────────────────────┐
│  Vuelve a:                   │
│  "Abrir Caja"                │
│  (nuevo turno disponible)    │
└──────────────────────────────┘
```

---

## 6. Auto-Cierre (Timeout)

```
[BACKGROUND — CADA 5 MIN EL SISTEMA VERIFICA]
      │
      ▼
┌────────────────────────────────────────────┐
│  ¿ business.closing_time + 180 min        │
│    < LocalDateTime.now()                  │
│    Y existe CashierSession con status=OPEN│
│    Y NO se ha notificado aún?             │
└─────────────┬──────────────────────────────┘
              │ (SÍ)
              ▼
┌────────────────────────────────────────────┐
│  1. Cerrar sesión automáticamente          │
│     status: AUTO_CLOSED                   │
│  2. Generar DailyCut                       │
│     status: AUTO_CLOSED                   │
│     actual_cash = lo que se tenga (null)   │
│  3. Crear Notification                     │
│     type: AUTO_CLOSE                       │
│     message: "Sucursal X - Turno auto-     │
│               cerrado por tiempo."         │
│  4. 🔔 al Patrón                           │
└────────────────────────────────────────────┘
```

---

## 7. Reportes del Patrón

```
[BOTÓN REPORTES]
      │
      ▼
┌────────────────────────────────────────────┐
│  ┌─────────────────┐                        │
│  │ CAJAS ABIERTAS  │  GET /reports/open-    │
│  │                 │       sessions         │
│  │  ─ Lista de     │                        │
│  │    sesiones     │  Resumen por caja:     │
│  │    activas      │  ─ transacciones       │
│  │  ─ Al seleccion │  ─ ventas totales      │
│  │    una:         │  ─ gastos              │
│  │    transacciones│                        │
│  │    del turno    │                        │
│  └─────────────────┘                        │
│                                             │
│  ┌─────────────────┐                        │
│  │ LISTA DE CORTES │  GET /reports/cuts     │
│  │                 │  Filtros:              │
│  │  Historial      │  ─ Sucursal            │
│  │  de cortes      │  ─ Cajero              │
│  │                 │  ─ Fecha (día, semana, │
│  │                 │    mes, período)       │
│  └─────────────────┘                        │
│                                             │
│  ┌─────────────────┐                        │
│  │ ESTADÍSTICAS    │  GET /reports/stats    │
│  │                 │                        │
│  │  Mejor semana   │  Comparativa:          │
│  │  vs             │  ─ total ventas        │
│  │  Semana activa  │  ─ transacciones       │
│  │                 │  ─ ticket promedio     │
│  └─────────────────┘                        │
└────────────────────────────────────────────┘
```

---

## 8. Sincronización (Offline-First)

```
[LOOP CADA 5 MIN — WORKER EN BACKGROUND]
      │
      ▼
┌────────────────────────────────────┐
│  ¿Hay conexión de red?            │
└─────────────┬──────────────────────┘
              │
         ┌────┴────┐
         ▼         ▼
       [SÍ]      [NO]
         │         │
         ▼         ▼
┌──────────────┐  ┌──────────────────────┐
│ Recopilar    │  │ Reintentar en        │
│ todos los    │  │ próximo ciclo (5min) │
│ registros    │  └──────────────────────┘
│ con          │
│ is_synced:   │
│ false        │
│              │
│ ─ transact.  │
│ ─ sesiones   │
│ ─ cortes     │
│ ─ productos  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ POST /sync   │
│ Enviar batch │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────┐
│ Backend procesa batch:       │
│ ─ Resuelve conflictos        │
│   (timestamp más reciente)   │
│ ─ Marca is_synced: true      │
│ ─ Devuelve resultado         │
└──────────────────────────────┘
```

---

## 9. Mapa de Navegación General

```
┌─────────────────────────────────────────────────────────────┐
│                    APP TACO'OS (Flutter)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [GOOGLE SIGN-IN]                                           │
│       │                                                     │
│       ▼                                                     │
│  [SELECCIÓN DE ROL]                                         │
│       │                                                     │
│  ┌────┴────┐                                                │
│  ▼         ▼                                                │
│ DUEÑO    CAJERO                                             │
│  │         │                                                │
│  │         ▼                                                │
│  │    [QR SCANNER]  ← bloqueado hasta enlazar              │
│  │         │                                                │
│  │    ┌────┴────┐                                           │
│  │    ▼         ▼                                           │
│  │ [ENLACE OK] [SIN ENLACE]                                │
│  │    │         │                                           │
│  │    ▼         ▼                                           │
│  │ [COBRO]  [Sigue escaneando]                             │
│  │                                                          │
│  ▼                                                          │
│┌────────────────┐                                           │
││ DASHBOARD      │                                           │
││ [VENTAS] ───> ─┼── TOGGLE ─────> ┌────────────────────┐  │
││ [REPORTES]     │                │   MODO CAJERO        │  │
││ [EQUIPO]       │                │                      │  │
││                │                │  ┌────────────────┐  │  │
││ ⚙️ Ajustes     │                │  │ ABRIR CAJA     │  │  │
││ ☰ Perfil       │                │  │ ─ fondo $___   │  │  │
││ 🔔 Notificac.  │                │  └───────┬────────┘  │  │
│└────────────────┘                │          │           │  │
│         │                        │          ▼           │  │
│         │ Reportes               │  ┌────────────────┐  │  │
│         ├── Cajas Abiertas       │  │ COBRO          │  │  │
│         ├── Lista Cortes         │  │ ─ catálogo     │  │  │
│         └── Estadísticas         │  │   (Comida,     │  │  │
│                                  │  │    Bebidas,    │  │  │
│         │ Equipo                 │  │    Postres)    │  │  │
│         ├── Lista cajeros        │  │ ─ teclado 9d  │  │  │
│         ├── QR nuevo             │  │ ─ cobrar      │  │  │
│         └── Desvincular          │  └───────┬────────┘  │  │
│                                  │          │           │  │
│         │ ⚙️ Ajustes             │          ▼           │  │
│         ├── Productos            │  ┌────────────────┐  │  │
│         ├── Sucursales (upsell)  │  │ FOOTER         │  │  │
│         └── Mi Plan (licencia)   │  │ [VENTAS]       │  │  │
│                                  │  │ [GASTOS]       │  │  │
│         │ ☰ Perfil               │  │ [¿CÓMO VOY?]  │  │  │
│         ├── Mi Perfil            │  └───────┬────────┘  │  │
│         ├── Dark Mode            │          │           │  │
│         └── Ayuda                │          ▼           │  │
│                                  │  ┌────────────────┐  │  │
│         │ 🔔 Notificaciones      │  │ CORTE          │  │  │
│         ├── Cancelaciones        │  │ ─ confirmación │  │  │
│         ├── Cut Differences      │  │ ─ resumen      │  │  │
│         └── Auto-Cierres         │  │ ─ conteo       │  │  │
│                                  │  │ ─ sobrante/    │  │  │
│                                  │  │   faltante     │  │  │
│                                  │  │ ─ ticket PDF   │  │  │
│                                  │  └────────────────┘  │  │
│                                  └──────────────────────┘  │
│                                                             │
│  [SYNC BACKGROUND CADA 5 MIN]                              │
│  ────> POST /sync                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. Diagrama de Flujo de Datos (Arquitectura)

```
┌────────────────────────────────────────────────────────┐
│                    DISPOSITIVO FLUTTER                  │
│  ┌────────────────────────────────────────────────┐    │
│  │              SQLite (Base Maestra)              │    │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐  │    │
│  │  │ local_    │  │ local_    │  │ local_    │  │    │
│  │  │ products  │  │ transact. │  │ sessions  │  │    │
│  │  └───────────┘  └───────────┘  └───────────┘  │    │
│  │  ┌───────────┐  ┌───────────┐                  │    │
│  │  │ local_    │  │ local_    │                  │    │
│  │  │ cuts      │  │ products  │                  │    │
│  │  └───────────┘  └───────────┘                  │    │
│  └──────────────────┬─────────────────────────────┘    │
│                     │                                   │
│              Background Worker (5 min)                 │
│                     │                                   │
│              POST /sync (is_synced: false)              │
└─────────────────────┼───────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────────────────┐
│                    BACKEND SPRING BOOT                  │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ Security │  │Controller│  │    Service Layer      │  │
│  │ JWT Auth │  │  Layer   │  │   @Transactional      │  │
│  │ Filter   │  │          │  │  ┌──────────────────┐│  │
│  └──────────┘  └──────────┘  │  │   Validators     ││  │
│                               │  │  ─ CancelWindow  ││  │
│  ┌──────────┐                 │  │  ─ LicenseLimit  ││  │
│  │ Mappers  │                 │  │  ─ Permission    ││  │
│  │ MapStruct│                 │  │  ─ SessionState  ││  │
│  └──────────┘                 │  └──────────────────┘│  │
│                               │  ┌──────────────────┐│  │
│  ┌──────────┐                 │  │    Helpers       ││  │
│  │Repository│                 │  │  ─ CashCalc      ││  │
│  │  Layer   │                 │  │  ─ JwtHelper     ││  │
│  └──────────┘                 │  │  ─ GoogleToken   ││  │
│                               │  │  ─ TicketGen     ││  │
│  ┌──────────┐                 │  └──────────────────┘│  │
│  │PostgreSQL│                 └──────────────────────┘  │
│  │(Esclavo) │                                           │
│  └──────────┘                                           │
└────────────────────────────────────────────────────────┘
```

---

## Leyenda de Flujos

| Símbolo | Significado |
|---------|-------------|
| `[ACCION]` | Pantalla o vista |
| `{ DATO }` | Información intercambiada |
| `POST /endpoint` | Llamada a API REST |
| `──>` | Flujo de acción |
| `─ ─>` | Flujo secundario o en background |
| `🔔` | Notificación push al Patrón |
| `(opcional)` | Acción no obligatoria |
