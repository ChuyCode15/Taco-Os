# Contratos API — Taco'Os v0.2 (Fase I)

> Documento de contratos y flujo del sistema.  
> Orientado a que Fanner (Flutter) y Jesús (Backend) trabajen sincronizados.  
> **Cada JSON coincide exactamente con lo que produce el backend (via @JsonProperty).**

---

## Índice

| Sección | Contenido |
|---------|-----------|
| **B-1** | Auth — Verificar Google ID |
| **B-2** | Auth — Registrar (Dueño o Cajero) |
| **C-1** | Negocio — Crear |
| **C-2** | Negocio — Detalle |
| **C-3** | Negocio — Editar |
| **C-4** | Negocio — Listar Cajeros |
| **D-1** | Enlace — Generar Invitación (Dueño) |
| **D-2** | Enlace — Enlazar Cajero (Cajero) |

> **Nota:** Los bloques A (Admin/Soporte) se posponen para Fase II. El sistema es auto-administrado por el dueño, sin Super Admin.

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

**Response 200 — Usuario existe (Dueño):**
```json
{
  "existe": true,
  "token": "dXNlci1pZDoxNzQ2NTk4NDAwMDAw",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "idGoogle": "1234567890",
    "nickname": "JuanRa",
    "correo": "juan@email.com",
    "rol": "dueño",
    "tieneNegocio": true,
    "negocioId": "550e8400-e29b-41d4-a716-446655440010",
    "negocioNombre": "Taquería Bonita"
  }
}
```

**Response 200 — Usuario existe (Cajero):**
```json
{
  "existe": true,
  "token": "dXNlci1pZDoxNzQ2NTk4NDAwMDAw",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440002",
    "idGoogle": "0987654321",
    "nickname": "PedroP",
    "correo": "pedro@email.com",
    "rol": "cajero",
    "tieneNegocio": true,
    "negocioId": "550e8400-e29b-41d4-a716-446655440010",
    "negocioNombre": "Taquería Bonita"
  }
}
```

| Campo | Descripción |
|-------|-------------|
| `token` | Base64(`userId:timestamp`). Placeholder — será JWT después. |
| `vencimiento` | 12 horas de vigencia del token |
| `rol` | `dueño` / `cajero` |
| `tieneNegocio` | `false` si el dueño aún no registra negocio |
| `negocioNombre` | `null` si no tiene negocio |

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
**Endpoint único:** El campo `rol` decide si se crea un dueño (administrador) o cajero.

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
| `rol` | Sí | `dueño` / `cajero` |

**Response 201 — Registro exitoso (Dueño):**
```json
{
  "token": "dXNlci1pZDoxNzQ2NTk4NDAwMDAw",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
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

**Response 201 — Registro exitoso (Cajero):**
```json
{
  "token": "dXNlci1pZDoxNzQ2NTk4NDAwMDAw",
  "vencimiento": 12,
  "usuario": {
    "id": "550e8400-e29b-41d4-a716-446655440002",
    "idGoogle": "0987654321",
    "nickname": "PedroP",
    "correo": "pedro@email.com",
    "rol": "cajero",
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
  "id": "550e8400-e29b-41d4-a716-446655440010",
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
  "id": "550e8400-e29b-41d4-a716-446655440010",
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
  "id": "550e8400-e29b-41d4-a716-446655440010",
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
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "nickname": "PedroP",
      "correo": "pedro@email.com",
      "numero": "+525598765432",
      "tieneSesionAbierta": false,
      "enlazadoEl": "2026-06-15T10:10:00"
    }
  ]
}
```

> `tieneSesionAbierta` es `false` por ahora (placeholder hasta implementar sesiones JWT).

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
  "negocioId": "550e8400-e29b-41d4-a716-446655440010",
  "duenoId": "550e8400-e29b-41d4-a716-446655440001"
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
| `expiraEn` | Minutos de vigencia del código (15) |
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
  "usuarioId": "550e8400-e29b-41d4-a716-446655440002"
}
```

**Response 200:**
```json
{
  "enlazado": true,
  "negocioId": "550e8400-e29b-41d4-a716-446655440010",
  "negocioNombre": "Taquería Bonita",
  "negocioDireccion": "Av. Principal 123",
  "moneda": "MXN",
  "dineroBase": 500.00
}
```

**Flutter:**
Redirige a la pantalla de cobro con los datos del negocio.

**Response 404 — Código inválido o expirado:**
```json
{
  "codigo": "NO_EXISTE",
  "mensaje": "El código de invitación no es válido o ya expiró",
  "ubicacion": "EnlaceService.enlazarCajero",
  "status": 404
}
```

---

## Resumen de Endpoints (Fase I — Implementados)

| Sec | Endpoint | Método | Controller | Status |
|-----|----------|--------|-----------|--------|
| B-1 | `/api/v1/auth/verificar/{idGoogle}` | GET | AuthController | ✅ |
| B-2 | `/api/v1/auth/registrar` | POST | AuthController | ✅ |
| C-1 | `/api/v1/business` | POST | negociosController | ✅ |
| C-2 | `/api/v1/business/{id}` | GET | negociosController | ✅ |
| C-3 | `/api/v1/business/{id}` | PUT | negociosController | ✅ |
| C-4 | `/api/v1/business/{id}/cajeros` | GET | negociosController | ✅ |
| D-1 | `/api/v1/business/invitation` | POST | EnlaceController | ✅ |
| D-2 | `/api/v1/business/link` | POST | EnlaceController | ✅ |

## Resumen de Endpoints (Fase I — Pendientes)

| Sec | Endpoint | Método |
|-----|----------|--------|
| 5.2 | `/api/v1/business/{id}/products` | GET |
| 5.2 | `/api/v1/business/{id}/products/{id}` | PUT |
| 5.2 | `/api/v1/business/{id}/products/{id}` | DELETE |
| 5.5 | `/api/v1/transactions` | POST |
| 6 | `/api/v1/cashier/close-session` | POST |
| 7 | `/api/v1/transactions/{id}/cancel` | POST |
| 10 | `/api/v1/sync` | POST |

---

## Cambios vs Contratos Originales (v1)

| Cambio | Original (v1) | v0.2 |
|--------|--------------|------|
| Registro auth | 2 endpoints separados (admin/cajero) | Único `POST /api/v1/auth/registrar` con campo `rol` |
| Roles en response | `ADMINISTRADOR` / `CAJERO` | `dueño` / `cajero` |
| Top-level `tipo` | Response tenía `tipo` al mismo nivel | Eliminado. El rol va dentro de `usuario.rol` |
| 404 verificar | Response `DatosError` genérico | Response específico: `{ existe, codigo, mensaje }` |
| `usuario` en auth | `tipo`, `nombreCompleto`, campos extra | Limpio: solo `id, idGoogle, nickname, correo, rol, tieneNegocio, negocioId, negocioNombre` |
| C-4 response | Lista plana de objetos | Envuelto en `{ cajeros: [...] }` |
| C-4 campos cajero | `nombreCompleto`, `permisos`, `activo` | Solo `id, nickname, correo, numero, tieneSesionAbierta, enlazadoEl` |
| D-2 `dineroBase` | No incluido en response original | Incluido como `dineroBase` |
| Nombres JSON | Algunos en inglés (`name`, `location`) | Español con @JsonProperty (`queVende`, `horario`, `creadoEl`) |
