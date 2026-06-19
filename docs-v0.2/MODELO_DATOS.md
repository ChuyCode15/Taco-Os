# Modelo de Datos — Taco'Os v0.2

> Entidades JPA, tablas, relaciones y campos. Refleja el código actual del backend.

---

## 1. Negocio (`negocios`)

| Campo | Columna DB | Tipo | Notas |
|-------|-----------|------|-------|
| `id` | `id` | `UUID` | PK, autogenerado |
| `nombre` | `name` | `String` | NOT NULL |
| `direccion` | `address` | `String` | NOT NULL |
| `telefono` | `phone` | `String` | NOT NULL |
| `giro` | `category` | `String` | Qué vende (ej: "Tacos, quesadillas") |
| `horarioCierre` | `closing_time` | `String` | HH:mm, opcional |
| `moneda` | `currency` | `String` | Default "MXN" |
| `dineroBase` | `base_money` | `BigDecimal` | Fondo de caja para cambio |
| `empleados` | `empleados` | `Integer` | Número de empleados registrado |
| `activo` | `activo` | `Boolean` | Default true |
| `registro` | `created_at` | `LocalDateTime` | @PrePersist automático |

### Relaciones
- Un Negocio tiene **muchos Administradores** (dueños)
- Un Negocio tiene **muchos Cajeros**
- Un Negocio tiene **muchos Productos**

---

## 2. Administrador (`administradores`)

| Campo | Columna DB | Tipo | Notas |
|-------|-----------|------|-------|
| `id` | `id` | `UUID` | PK, autogenerado |
| `idGoogle` | `google_id` | `String` | NOT NULL, UNIQUE |
| `nombreCompleto` | `full_name` | `String` | NOT NULL |
| `nickname` | `nickname` | `String` | Cómo quiere que le digan |
| `correo` | `email` | `String` | NOT NULL |
| `numero` | `phone` | `String` | Teléfono |
| `negocio` | `business_id` | `@ManyToOne` | FK → Negocio (puede ser null) |
| `tipoPlan` | `plan_type` | `@Enumerated(EnumType.STRING)` | FREE, PREMIUM, BUSINESS |
| `estadoPlan` | `plan_status` | `@Enumerated(EnumType.STRING)` | PAGADO, VENCIDO, SUSPENDIDO, etc. |
| `fechaVencimiento` | `due_date` | `LocalDate` | Vencimiento del plan |
| `activo` | `activo` | `Boolean` | Default true |
| `registro` | `created_at` | `LocalDateTime` | @PrePersist |

---

## 3. Cajero (`cajeros`)

| Campo | Columna DB | Tipo | Notas |
|-------|-----------|------|-------|
| `id` | `id` | `UUID` | PK, autogenerado |
| `idGoogle` | `google_id` | `String` | NOT NULL, UNIQUE |
| `nombreCompleto` | `full_name` | `String` | NOT NULL |
| `nickname` | `nickname` | `String` | Cómo quiere que le digan |
| `correo` | `email` | `String` | NOT NULL |
| `numero` | `phone` | `String` | Teléfono |
| `negocio` | `business_id` | `@ManyToOne` | FK → Negocio (inicialmente null, se asigna via link) |
| `permisos` | `permissions` | `String` (TEXT) | JSON con permisos |
| `fechaEnlace` | `linked_at` | `LocalDateTime` | Cuándo se enlazó al negocio |
| `activo` | `activo` | `Boolean` | Default true |
| `registro` | `created_at` | `LocalDateTime` | @PrePersist |

---

## 4. Invitación (`invitacion`)

Para el flujo de QR + enlace (D-1 / D-2).

| Campo | Columna DB | Tipo | Notas |
|-------|-----------|------|-------|
| `id` | `id` | `UUID` (Long?) | PK |
| `negocioId` | `negocio_id` | `UUID` | FK lógica → Negocio |
| `duenoId` | `dueno_id` | `UUID` | FK lógica → Administrador |
| `codigo` | `codigo` | `String` | Código de invitación (ej: "INV-a1b2c3d4") |
| `expiraEn` | `expira_en` | `LocalDateTime` | 15 min después de creación |
| `activo` | `activo` | `Boolean` | Se desactiva al usar o expirar |

---

## 5. Producto (`productos`)

| Campo | Columna DB | Tipo | Notas |
|-------|-----------|------|-------|
| `id` | `id` | `UUID` | PK |
| `nombre` | `name` | `String` | NOT NULL |
| `precio` | `price` | `BigDecimal` | NOT NULL |
| `categoria` | `category` | `@Enumerated(EnumType.STRING)` | COMIDA, BEBIDAS, POSTRES |
| `negocio` | `business_id` | `@ManyToOne` | FK → Negocio |
| `activo` | `activo` | `Boolean` | Default true |
| `registro` | `created_at` | `LocalDateTime` | @PrePersist |

---

## 6. Planes y Estados

### TipoPlan
```java
FREE, PREMIUM, BUSINESS
```

### EstadoPlan
```java
TRIAL_PREMIUM, TRIAL_BUSINESS, PAGADO, VENCIDO, SUSPENDIDO
```

### Categoria
```java
COMIDA, BEBIDAS, POSTRES
```

---

## 7. Mapeo JSON (@JsonProperty)

Los DTOs usan `@JsonProperty` para que el JSON que viaja entre backend y Flutter coincida exactamente con el contrato:

| DTO | Campo Java | JSON |
|-----|-----------|------|
| `DatosRegistroNegocio` | `giro` | `queVende` |
| `DatosRegistroNegocio` | `horarioCierre` | `horario` |
| `DatosDetalleNegocio` | `giro` | `queVende` |
| `DatosDetalleNegocio` | `horarioCierre` | `horario` |
| `DatosDetalleNegocio` | `registro` | `creadoEl` |
| `DatosRegistroAuth` | `idGoogle` | `idGoogle` |
| `DatosUsuarioAuth` | `idGoogle` | `idGoogle` |
| `DatosUsuarioAuth` | `tieneNegocio` | `tieneNegocio` |
| `DatosListaCajero` | `tieneSesionAbierta` | `tieneSesionAbierta` |
| `DatosListaCajero` | `fechaEnlace` | `enlazadoEl` |
| `DatosRespuestaEnlace` | `dineroBase` | `dineroBase` |

---

## 8. Cambios vs Modelo Original (v1)

| Cambio | v1 (original) | v0.2 (actual) |
|--------|--------------|---------------|
| Tabla usuarios | Tabla única `usuarios` con `rol` | Tablas separadas `administradores` + `cajeros` |
| Roles en DB | `ADMINISTRADOR` / `CAJERO` | En response: `dueño` / `cajero` |
| dineroBase | Eliminado del modelo | Restaurado en `Negocio` |
| empleados | Calculado via COUNT de cajeros | Campo almacenado en `negocios` |
| fechaEnlace | No existía | Nuevo campo en `Cajero` (linked_at) |
| Packages | `com.tacoos` | `com.jmcsoft.taco_os` |
| DTOs | Clases mutables | Records de Java con @JsonProperty |
