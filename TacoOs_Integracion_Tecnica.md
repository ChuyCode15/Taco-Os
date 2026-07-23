# Taco'Os — Integración Técnica (Fase I)

> Documento de contratos y flujo del sistema.
> Orientado a que Fanner (Flutter) y Jesús (Backend) trabajen sincronizados.

---

## Índice

| Sección | Contenido                           |
|---------|-------------------------------------|
| **A-1** | Admin — Listar Usuarios             |
| **A-2** | Admin — Detalle de Usuario          |
| **A-3** | Admin — Listar Negocios             |
| **B-1** | Autorizacion — Verificar Google ID  |
| **B-2** | Autorizacion — Registrar Nuevo Usuario      |
| **C-1** | Negocio — Crear                     |
| **C-2** | Negocio — Detalle                   |
| **C-3** | Negocio — Editar                    |
| **C-4** | Negocio — Listar Cajeros            |
| **D-1** | Enlace — Generar Invitación (Dueño) |
| **D-2** | Enlace — Enlazar Cajero (Cajero)    |

---

## A — ADMIN / SOPORTE (Diagnóstico)

> Endpoints para que el equipo de soporte pueda ver el estado del sistema.
> Solo accesible por Super Admin. Filtros para encontrar rápidamente usuarios y negocios.

---

### A-1 `GET /api/v1/admin/usuarios`

**Propósito:** Listar todos los usuarios registrados, con filtro opcional por nombre, rol o negocio.

**Request:**
```
GET /api/v1/admin/usuarios?filtro=juan&rol=dueño&pagina=1&tamano=20
```

| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| `filtro` | String | No | Busca por nickname, correo o idGoogle |
| `rol` | String | No | dueño / cajero |
| `pagina` | Integer | No | Número de página (default: 1) |
| `tamano` | Integer | No | Resultados por página (default: 20) |

**Response 200:**
```json
{
  "usuarios": [
    {
      "id": "uuid",
      "idGoogle": "1234567890",
      "nickname": "JuanRa",
      "correo": "juan@email.com",
      "numero": "+525512345678",
      "rol": "dueño",
      "negocioId": "uuid",
      "negocioNombre": "Taquería Bonita",
      "activo": true,
      "creadoEl": "2026-06-15T10:00:00"
    }
  ],
  "totalPaginas": 1,
  "totalResultados": 1
}
```

---

### A-2 `GET /api/v1/admin/usuarios/{id}`

**Propósito:** Obtener detalle completo de un usuario específico (para diagnóstico).

**Response 200:**
```json
{
  "id": "uuid",
  "idGoogle": "1234567890",
  "nickname": "JuanRa",
  "correo": "juan@email.com",
  "numero": "+525512345678",
  "rol": "dueño",
  "negocioId": "uuid",
  "negocioNombre": "Taquería Bonita",
  "activo": true,
  "creadoEl": "2026-06-15T10:00:00"
}
```

---

### A-3 `GET /api/v1/admin/negocios`

**Propósito:** Listar todos los negocios registrados, con filtro opcional.

**Request:**
```
GET /api/v1/admin/negocios?filtro=taqueria&pagina=1&tamano=20
```

**Response 200:**
```json
{
  "negocios": [
    {
      "id": "uuid",
      "nombre": "Taquería Bonita",
      "direccion": "Av. Principal 123",
      "telefono": "+525512345678",
      "queVende": "Tacos, quesadillas, bebidas",
      "empleados": "2",
      "horario": "18:00",
      "creadoEl": "2026-06-15T10:05:00"
    }
  ],
  "totalPaginas": 1,
  "totalResultados": 1
}
```

---

## B — AUTENTICACIÓN (Entrada al Sistema)

> Flujo completo desde que el usuario hace login con Google hasta que entra al sistema.

---

### B-1 `GET /api/v1/auth/verificar/{idGoogle}`

**Propósito:** La app consulta si el usuario ya existe en el sistema después del login de Google.

**Lo que pasa del lado del cliente:**
1. Usuario abre la app
2. Aparece el flujo de Google Sign-In
3. Usuario selecciona su cuenta de Google
4. Google devuelve un `idGoogle` (único, siempre el mismo por cuenta)
5. App consulta: `GET /api/v1/auth/verificar/{idGoogle}`

**Response 200 — Usuario existe:**
```json
{
  "existe": true,
  "token": "eyJhbGciOiJIUzI1...",
  "vencimiento": 12,
  "usuario": {
    "id": "uuid",
    "idGoogle": "1234567890",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "rol": "dueño",
    "tieneNegocio": true,
    "negocioId": "uuid",
    "negocioNombre": "Taquería Bonita"
  }
}
```

| Campo | Descripción |
|-------|-------------|
| `token` | JWT con sesión de 12 horas |
| `vencimiento` | Horas de vigencia del token |
| `rol` | dueño / cajero |
| `tieneNegocio` | false si el dueño aún no registra negocio |
| `negocioNombre` | null si no tiene negocio |

**Flutter decide:**
- `rol` = dueño + `tieneNegocio` = true → Dashboard Patrón
- `rol` = dueño + `tieneNegocio` = false → Vista "Registrar tu negocio"
- `rol` = cajero + `tieneNegocio` = true → Pantalla de cobro
- `rol` = cajero + `tieneNegocio` = false → Error (cajero debería tener negocio)

---

**Response 404 — Usuario nuevo (no existe):**
```json
{
  "existe": false,
  "codigo": "NO_REGISTRADO",
  "mensaje": "Usuario no encontrado. Debe registrarse."
}
```

**Flutter decide:**
Muestra pantalla: *"¿Eres Dueño de negocio o Cajero?"*

---

### B-2 `POST /api/v1/auth/registrar`

**Propósito:** Registrar un usuario nuevo después de que eligió su rol.

**Request:**
```json
{
  "idGoogle": "1234567890",
  "nickname": "JuanRa",
  "correo": "juan@email.com",
  "numero": "+525512345678",
  "rol": "dueño"
}
```

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `idGoogle` | Sí | ID único de Google |
| `nickname` | Sí | Cómo quiere que le digan |
| `correo` | Sí | Correo de Google |
| `numero` | No | Teléfono del usuario |
| `rol` | Sí | dueño / cajero |

**Response 201 — Registro exitoso:**
```json
{
  "token": "eyJhbGciOiJIUzI1...",
  "vencimiento": 12,
  "usuario": {
    "id": "uuid",
    "idGoogle": "1234567890",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "rol": "dueño",
    "tieneNegocio": false,
    "negocioId": null,
    "negocioNombre": null
  }
}
```

**Flutter decide:**
- dueño → Vista "Registrar tu negocio"
- cajero → Abre cámara para escanear QR o ingresar código

**Response 409 — Ya registrado:**
```json
{
  "codigo": "YA_EXISTE",
  "mensaje": "El usuario con idGoogle 1234567890 ya está registrado",
  "ubicacion": "AuthService.registrar",
  "status": 409
}
```

---

## C — NEGOCIOS (Dueño)

> Endpoints para que el dueño administre su negocio.

---

### C-1 `POST /api/v1/business`

**Propósito:** El dueño registra su negocio por primera vez.

**Lo que pasa del lado del cliente:**
1. Dueño elige "Dueño" en B-2
2. Ve formulario: nombre, dirección, teléfono, qué vende, empleados (horario opcional)
3. Llena y confirma
4. App envía POST

**Request:**
```json
{
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00"
}
```

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `nombre` | Sí | Nombre del negocio |
| `direccion` | Sí | Dirección completa |
| `telefono` | Sí | Teléfono de contacto |
| `queVende` | No | Descripción de lo que venden |
| `empleados` | No | Número de empleados |
| `horario` | No | Hora de cierre (HH:mm), para auto-cierre |

**Response 201:**
```json
{
  "id": "uuid",
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00",
  "creadoEl": "2026-06-15T10:05:00"
}
```

**Flutter:**
Redirige al Dashboard Patrón.

---

### C-2 `GET /api/v1/business/{id}`

**Propósito:** Obtener detalle del negocio.

**Response 200:**
```json
{
  "id": "uuid",
  "nombre": "Taquería Bonita",
  "direccion": "Av. Principal 123, Col. Centro",
  "telefono": "+525512345678",
  "queVende": "Tacos, quesadillas, bebidas",
  "empleados": 3,
  "horario": "23:00",
  "creadoEl": "2026-06-15T10:05:00"
}
```

**Response 404:**
```json
{
  "codigo": "NO_EXISTE",
  "mensaje": "Negocio no encontrado",
  "ubicacion": "NegocioService.obtenerDetalle",
  "status": 404
}
```

---

### C-3 `PUT /api/v1/business/{id}`

**Propósito:** Editar datos del negocio.

**Request:**
```json
{
  "nombre": "Taquería Bonita (Sucursal Centro)",
  "direccion": "Av. Principal 456",
  "telefono": "+525512345679",
  "queVende": "Tacos, quesadillas, bebidas, postres",
  "empleados": 4,
  "horario": "22:00"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "nombre": "Taquería Bonita (Sucursal Centro)",
  "direccion": "Av. Principal 456",
  "telefono": "+525512345679",
  "queVende": "Tacos, quesadillas, bebidas, postres",
  "empleados": 4,
  "horario": "22:00",
  "creadoEl": "2026-06-15T10:05:00"
}
```

---

### C-4 `GET /api/v1/business/{id}/cajeros`

**Propósito:** Dueño consulta la lista de cajeros enlazados a su negocio.

**Response 200:**
```json
{
  "cajeros": [
    {
      "id": "uuid",
      "nickname": "PedroP",
      "correo": "pedro@email.com",
      "numero": "+525598765432",
      "tieneSesionAbierta": true,
      "enlazadoEl": "2026-06-15T10:10:00"
    }
  ]
}
```

**Response 404:**
```json
{
  "codigo": "NO_EXISTE",
  "mensaje": "Negocio no encontrado",
  "status": 404
}
```

---

## D — ENLACE CAJERO (QR Handshake)

> Flujo donde el dueño genera una invitación y el cajero se enlaza al negocio.

---

### D-1 `POST /api/v1/business/invitation`

**Propósito:** El dueño genera un código de invitación para que un cajero se enlace. El backend devuelve un token temporal que el dueño convierte en QR.

**Request:**
```json
{
  "negocioId": "uuid",
  "duenoId": "uuid"
}
```

**Response 201:**
```json
{
  "codigo": "INV-a1b2c3d4",
  "expiraEn": 15,
  "qrPayload": "tacoos://link?codigo=INV-a1b2c3d4"
}
```

| Campo | Descripción |
|-------|-------------|
| `codigo` | Código alfanumérico de 8 caracteres |
| `expiraEn` | Minutos de vigencia del código |
| `qrPayload` | Texto que codifica el QR, incluye el código |

**Lo que hace Flutter:**
Dueño ve el código en pantalla y un QR generado localmente. El cajero puede escanear el QR o escribir el código manualmente.

---

### D-2 `POST /api/v1/business/link`

**Propósito:** El cajero se enlaza al negocio usando el código de invitación.

**Lo que pasa del lado del cliente:**
1. Cajero se registró con rol "cajero"
2. App abre cámara QR (o input manual)
3. Cajero escanea QR o escribe código
4. App envía POST con el código y su id de usuario

**Request:**
```json
{
  "codigo": "INV-a1b2c3d4",
  "usuarioId": "uuid"
}
```

**Response 200:**
```json
{
  "enlazado": true,
  "negocioId": "uuid",
  "negocioNombre": "Taquería Bonita",
  "negocioDireccion": "Av. Principal 123",
  "moneda": "MXN",
  "dineroBase": 500.00
}
```

**Flutter:**
Redirige a la pantalla de cobro con los datos del negocio.

**Response 409 — Código inválido o expirado:**
```json
{
  "codigo": "NO_EXISTE",
  "mensaje": "El código de invitación no es válido o ya expiró",
  "ubicacion": "EnlaceService.enlazar",
  "status": 404
}
```

---

## Relación con otros documentos

| Documento | Contenido |
|-----------|-----------|
| `README.md` | Visión general del producto, fases, equipo |
| `TacoOs_Diseno_Tecnico_Consolidado.md` | Arquitectura completa, modelo de datos, UX |
| `TacoOs_Flujo_Desarrollo.md` | Asignación de tareas y criterios de completitud |
| `TacoOs_Flujo_Completo_Sistema.md` | Mapa de flujo del sistema completo |
| **Este documento** | Contratos API con JSON, flujo por bloque |

---

## Historial de Cambios

| Fecha | Cambio |
|-------|--------|
| 2026-06-15 | Creación inicial. Bloques A, B, C, D definidos |
