# Ajustes vs Documentación Original — Taco'Os v0.2

> Lista exhaustiva de todos los cambios y decisiones tomadas durante la conversación que modifican la documentación original (v1 → v0.2).

---

## 1. Package Base

| Antes | Después | Razón |
|-------|---------|-------|
| `com.tacoos` / `com.tacoos.taco_os` | `com.jmcsoft.taco_os` | Se eliminó `com.tacoos` (dominio no propio). Se usa `com.jmcsoft.taco_os` con guión bajo. |

---

## 2. Idioma

| Antes | Después | Razón |
|-------|---------|-------|
| Clases en inglés (`User`, `Business`, `Product`) | Español (`Administrador`, `Negocio`, `Producto`) | Decisión del dueño: todo en español |
| Métodos en inglés (`verifyUser`, `registerBusiness`) | Español (`verificarUsuario`, `registrarNegocio`) | Decisión del dueño |
| URLs mixtas | URLs en inglés, métodos en español | Decisión del dueño |

---

## 3. Estructura de Directorios

| Antes | Después | Razón |
|-------|---------|-------|
| `model/`, `dto/`, `mapper/` separados | `domain/{entidad}/` con todo adentro | Agrupación por dominio |
| `service/` con interfaz + impl | `services/` solo clases concretas | Simpleza, sin interfaz innecesaria |
| `helper/` genérico | `common/helper/` con helpers por entidad | Validación especializada |
| Paquete `usuario` | `administrador` + `cajero` separados | Tablas separadas por rol |

---

## 4. Tablas Separadas (Decisión Crítica)

| Antes | Después |
|-------|---------|
| Una tabla `usuarios` con columna `rol` (DUEÑO/CAJERO/ADMIN) | Tablas separadas: `negocios`, `administradores`, `cajeros` |
| Auth buscaba en una sola tabla | Auth busca primero en `administradores`, luego en `cajeros`, si no → 404 |

**Razón:** Eficiencia a escala. Tabla de admins (~20k regs) se consulta primero. Cajeros (~100k regs) solo si no es admin.

---

## 5. Auth — Cambios Principales

| Concepto | Antes | Después |
|----------|-------|---------|
| Registro | `POST /registrar/administrador` + `POST /registrar/cajero` | Único `POST /api/v1/auth/registrar` con campo `rol` |
| Roles | `ADMINISTRADOR` / `CAJERO` | `dueño` / `cajero` |
| Response top-level | `{ tipo, token, vencimiento, usuario }` | `{ token, vencimiento, usuario }` (sin `tipo` al mismo nivel) |
| 404 verificar | `DatosError` genérico: `{ codigo, mensaje, ubicacion, status }` | Response específico: `{ existe: false, codigo: "NO_REGISTRADO", mensaje: "..." }` |
| User object | Tenía `tipo`, `nombreCompleto`, campos extra | Solo: `id, idGoogle, nickname, correo, rol, tieneNegocio, negocioId, negocioNombre` |
| Token | JWT (planeado) | Base64 placeholder (`userId:timestamp`) |

---

## 6. Negocio — Cambios

| Concepto | Antes | Después |
|----------|-------|---------|
| `empleados` | Calculado via COUNT | Campo almacenado en entidad |
| `dineroBase` | Eliminado | Restaurado (está en el contrato D-2) |
| Response fields | Incluía `moneda`, `activo`, `registro` | Solo contrato: `id, nombre, direccion, telefono, queVende, empleados, horario, creadoEl` |
| `@JsonProperty` | No se usaba | `giro → queVende`, `horarioCierre → horario`, `registro → creadoEl` |

---

## 7. Lista de Cajeros (C-4) — Cambios

| Concepto | Antes | Después |
|----------|-------|---------|
| Response wrapper | Lista plana | `{ cajeros: [...] }` |
| Campos | `id, nombreCompleto, nickname, correo, numero, permisos, activo` | `id, nickname, correo, numero, tieneSesionAbierta, enlazadoEl` |
| `tieneSesionAbierta` | No existía | Agregado (false placeholder) |
| `enlazadoEl` | No existía | Mapeado de `fechaEnlace` |

---

## 8. Enlace Cajero — Cambios

| Concepto | Antes | Después |
|----------|-------|---------|
| Link endpoint | `POST /api/v1/business/link-cashier` | `POST /api/v1/business/link` |
| Link request | Incluía `name`, `email`, `phone`, `device_id` | Solo `codigo`, `usuarioId` (el cajero ya está registrado) |
| Link response | `{ status, business: { id, name, currency, base_cash }, owner: { name, phone } }` | `{ enlazado, negocioId, negocioNombre, negocioDireccion, moneda, dineroBase }` |
| `fechaEnlace` | No existía | Se guarda `LocalDateTime` al enlazar |

---

## 9. Helpers — Cambios

| Antes | Después |
|-------|---------|
| `UsuarioHelper` (genérico) | `AdministradorHelper` + `CajeroHelper` (específicos) |
| Validación inline en services | Helpers con métodos: `validarIdNegocio()`, `validarIdAdministrador()`, `validarGoogleNoRegistrado()`, `negocioYaRegistrado()` |

---

## 10. Excepciones — Cambios

| Antes | Después |
|-------|---------|
| Pocas excepciones definidas | 6 excepciones: `DuplicadoException`, `YaExisteException`, `YaRegistradoException` (409), `NoExisteException` (404), `NoAutorizadoException` (403), `NoAutenticadoException` (401) |
| Manejo genérico | `GlobalExceptionHandler` con `DatosError { codigo, mensaje, ubicacion, status }` |

---

## 11. Archivos Eliminados

| Archivo | Razón |
|---------|-------|
| `AdminController.java` | No hay soporte/admin en Fase I |
| `AdminService.java` | No hay soporte/admin en Fase I |
| `AutorizacionController.java` | Duplicado de AuthController |
| `AutorizacionService.java` | Duplicado de AuthService |
| `domain/usuario/` (todo) | Tabla única reemplazada por administrador + cajero |
| `domain/admin/` (todo) | No hay soporte/admin en Fase I |
| `UsuarioHelper.java` | Reemplazado por helpers específicos |
| `UsuarioRepository.java` | Reemplazado por repos específicos |
| `RolUsuario.java` | Roles movidos a strings "dueño"/"cajero" |

---

## 12. Documentos Creados (docs-v0.2/)

| Documento | Contenido |
|-----------|-----------|
| `README.md` | Proyecto, filosofía, stack, fases |
| `ARQUITECTURA.md` | Estructura, paquetes, convenciones, excepciones |
| `CONTRATOS_API.md` | Endpoints, JSON exactos con @JsonProperty |
| `MODELO_DATOS.md` | Entidades, tablas, campos, relaciones |
| `FLUJO_DESARROLLO.md` | Tareas, asignación, Definition of Done |
| `PLAN_CONSTRUCCION.md` | 25 piezas de construcción |
| `AJUSTES.md` | Este documento — todos los cambios vs original |

---

## 13. Decisiones de Arquitectura Clave (Registro)

1. **Tablas separadas** en vez de tabla única `usuarios` → eficiencia a escala
2. **Auth ordenado**: busca admin (tabla chica) → cajero (tabla grande) → 404
3. **Controller max 4 líneas**: recibe → llama service → construye URI → retorna ResponseEntity
4. **Helper valida IDs**: recibe String, valida null/vacío/UUID inválido, busca en DB, lanza excepción
5. **@JsonProperty** sincroniza nombres del contrato con nombres Java
6. **Token base64 placeholder** → será JWT con Spring Security después
7. **Sin soporte/admin**: sistema auto-administrado, dueño es el único admin
8. **`empleados` almacenado** (no calculado) — viene del formulario de registro
9. **`dineroBase` restaurado** — está en el contrato D-2
10. **Sin JWT ni Spring Security** en Fase I — token placeholder suficiente para MVP

---

*Documento generado el 2026-06-18. Refleja todas las decisiones tomadas durante la conversación de refactor v0.2.*
