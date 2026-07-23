# Flujo Completo del Sistema — Taco'Os v0.2

> Mapas de flujo actualizados con los cambios de arquitectura v0.2.

---

## 1. Flujo de Auth (v0.2)

```
[USUARIO NUEVO]
      │
      ▼
┌──────────────────────┐
│  Google Sign-In      │
│  → idGoogle          │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────────────┐
│  GET /api/v1/auth/verificar/{idGoogle}        │
│                                              │
│  1. ❓ ¿Existe en administradores?            │
│     ├── Sí → return { rol: "dueño", ... }    │
│     │                                         │
│  2. ❓ ¿Existe en cajeros?                    │
│     ├── Sí → return { rol: "cajero", ... }   │
│     │                                         │
│  3. ❓ No existe en ninguna tabla             │
│     └── return 404 { existe: false,           │
│                      codigo: "NO_REGISTRADO", │
│                      mensaje: "..." }         │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
         ┌─────────────────────────┐
         │  USUARIO ELIGE ROL      │
         │  ───────────────────    │
         │  "Soy Dueño"            │
         │  "Soy Cajero"           │
         └──────────┬──────────────┘
                    │
               ┌────┴────┐
               ▼         ▼
         ┌─────────┐ ┌──────────────────────┐
         │ DUEÑO   │ │ CAJERO               │
         │         │ │                      │
         │ POST    │ │ POST                 │
         │ /auth/  │ │ /auth/registrar      │
         │registrar│ │ { rol: "cajero" }    │
         │{rol:    │ │                      │
         │"dueño"} │ │ → Cámara QR se abre │
         │         │ │ → Escanea código     │
         │ → Crear │ │ → POST /link         │
         │ negocio │ │ → Pantalla de cobro  │
         └─────────┘ └──────────────────────┘
```

---

## 2. Flujo de Registro de Negocio (v0.2)

```
[DUEÑO — SIN NEGOCIO]
      │
      ▼
┌────────────────────────────────────────────┐
│  Formulario:                               │
│  ─ nombre, direccion, telefono             │
│  ─ queVende (opcional)                     │
│  ─ empleados (opcional)                    │
│  ─ horario cierre (opcional)               │
└──────────────────┬─────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────┐
│  POST /api/v1/business?duenoId={uuid}       │
│  Body: { nombre, direccion, telefono,       │
│          queVende, empleados, horario }      │
│                                             │
│  Backend:                                   │
│  1. Valida que nombre no esté registrado    │
│  2. Valida que duenoId exista               │
│  3. Crea Negocio                            │
│  4. Asigna dueño → dueno.setNegocio(neg)    │
│  5. Return negocio creado                   │
└──────────────────┬─────────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Dashboard Patrón   │
         │  3+1+1+🔔          │
         └─────────────────────┘
```

---

## 3. Flujo de Enlace Cajero (v0.2)

```
[PATRÓN]                          [CAJERO]
   │                                  │
   │ Abre "Equipo"                    │ Se registró como cajero
   │ → "Registrar Nuevo"              │ → Cámara QR se abre
   │                                  │
   ▼                                  ▼
┌──────────────────┐            ┌──────────────┐
│ POST /invitation │            │ Escanea QR   │
│ { negocioId,     │            │ o escribe    │
│   duenoId }      │            │ código       │
└────────┬─────────┘            └──────┬───────┘
         │                             │
         ▼                             ▼
   ┌──────────────┐            ┌──────────────────┐
   │ Response:     │            │ POST /link       │
   │ codigo:       │◄───────────│ { codigo,        │
   │ "INV-a1b2..." │            │   usuarioId }    │
   │ expiraEn: 15  │            └────────┬─────────┘
   │ qrPayload:    │                     │
   │ "tacoos://.." │                     ▼
   └──────────────┘            ┌──────────────────────┐
                               │ Backend:             │
                               │ 1. Valida código     │
                               │ 2. Valida expiración │
                               │ 3. Asigna negocio    │
                               │ 4. Guarda fechaEnlace│
                               │ 5. Desactiva código  │
                               └──────────┬───────────┘
                                          │
                                          ▼
                               ┌──────────────────────┐
                               │ Response:             │
                               │ enlazado: true        │
                               │ negocioId, nombre     │
                               │ direccion, moneda     │
                               │ dineroBase: 500.00    │
                               └──────────────────────┘
                                          │
                                          ▼
                               ┌──────────────────────┐
                               │ Pantalla de cobro    │
                               └──────────────────────┘
```

---

## 4. Mapa de Endpoints (Fase I — v0.2)

```
AUTH (B)
├── GET  /api/v1/auth/verificar/{idGoogle}    ← Verificar existencia
└── POST /api/v1/auth/registrar               ← Registrar (dueño/cajero)

NEGOCIO (C)
├── POST /api/v1/business                     ← Crear negocio
├── GET  /api/v1/business/{id}                ← Detalle negocio
├── PUT  /api/v1/business/{id}                ← Editar negocio
└── GET  /api/v1/business/{id}/cajeros        ← Lista cajeros

ENLACE (D)
├── POST /api/v1/business/invitation          ← Generar código QR
└── POST /api/v1/business/link                ← Enlazar cajero

PRODUCTOS (Pendiente)
├── GET  /api/v1/business/{id}/products       ← Listar por categoría
├── POST /api/v1/business/{id}/products       ← Crear
├── PUT  /api/v1/business/{id}/products/{id}  ← Editar
└── DELETE /api/v1/business/{id}/products/{id} ← Eliminar

TRANSACCIONES (Pendiente)
├── POST /api/v1/cashier/open-session         ← Abrir caja
├── POST /api/v1/transactions                 ← Venta/Gasto
├── POST /api/v1/cashier/close-session        ← Corte
└── POST /api/v1/transactions/{id}/cancel     ← Cancelar

SISTEMA (Pendiente)
├── POST /api/v1/sync                         ← Sincronización batch
├── GET  /api/v1/business/{id}/reports/*      ← Reportes
├── GET  /api/v1/business/{id}/notifications  ← Notificaciones
└── GET  /api/v1/plans                        ← Planes/licencias
```

---

## 5. Arquitectura Backend (v0.2)

```
HTTP REQUEST
     │
     ▼
┌─────────────────────────────────────────────────────┐
│  CONTROLLER (≤4 líneas)                              │
│  • Recibe HTTP, delega al Service                    │
│  • Construye URI (POST) / retorna ResponseEntity     │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  SERVICE (clase concreta, sin interfaz)              │
│  • Lógica de negocio                                 │
│  • @Transactional en cada método público             │
│  • Llama a Helpers antes de persistir                │
└──────────┬──────────────────────┬───────────────────┘
           │                      │
           ▼                      ▼
┌──────────────────┐  ┌──────────────────────────────┐
│  HELPER           │  │  MAPPER (MapStruct)          │
│  • Valida IDs     │  │  • Request → Entity          │
│  • Valida unicidad│  │  • Entity → Response         │
│  • Lanza excepción│  │  • componentModel="spring"   │
└──────────────────┘  └──────────────────────────────┘
           │                      │
           ▼                      ▼
┌─────────────────────────────────────────────────────┐
│  REPOSITORY (Spring Data JPA)                       │
│  • JpaRepository<Entidad, UUID>                     │
│  • Queries personalizadas: findByIdGoogle, etc.     │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  DATABASE                                            │
│  • H2 (desarrollo) / PostgreSQL (producción)         │
│  • Flyway migrations + ddl-auto: update              │
└─────────────────────────────────────────────────────┘
```
