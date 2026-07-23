# Arquitectura del Backend — Taco'Os v0.2

> Documento de diseño técnico: estructura, convenciones, paquetería y decisiones de arquitectura.

---

## 1. Package Base

```
com.jmcsoft.taco_os
```

> Cambio clave: se eliminó `com.tacoos` (dominio no propio). Ahora usa `com.jmcsoft.taco_os` con guión bajo en `taco_os`.

---

## 2. Estructura de Directorios

```
com.jmcsoft.taco_os/
├── SistemaGlobalApplication.java
├── common/
│   ├── dto/
│   │   └── DatosError.java
│   ├── enums/
│   │   ├── Categoria.java        // COMIDA, BEBIDAS, POSTRES
│   │   ├── EstadoPlan.java       // TRIAL_PREMIUM, TRIAL_BUSINESS, PAGADO, VENCIDO, SUSPENDIDO
│   │   └── TipoPlan.java         // FREE, PREMIUM, BUSINESS
│   ├── exception/
│   │   ├── DuplicadoException.java      // 409
│   │   ├── GlobalExceptionHandler.java   // @RestControllerAdvice
│   │   ├── NoAutenticadoException.java   // 401
│   │   ├── NoAutorizadoException.java    // 403
│   │   ├── NoExisteException.java        // 404
│   │   ├── YaExisteException.java        // 409
│   │   └── YaRegistradoException.java    // 409
│   └── helper/
│       ├── AdministradorHelper.java
│       ├── CajeroHelper.java
│       ├── NegocioHelper.java
│       └── ProductoHelper.java
├── controller/
│   ├── AuthController.java
│   ├── EnlaceController.java
│   ├── negociosController.java
│   └── ProductoController.java
├── domain/
│   ├── administrador/
│   │   ├── Administrador.java
│   │   ├── dto/
│   │   │   ├── DatosDetalleAdmin.java
│   │   │   ├── DatosListaAdmin.java
│   │   │   └── DatosRegistroAdmin.java
│   │   └── mapper/
│   │       └── AdministradorMapper.java
│   ├── auth/
│   │   └── dto/
│   │       ├── DatosRegistroAuth.java
│   │       ├── DatosRespuestaAuth.java
│   │       ├── DatosUsuarioAuth.java
│   │       └── DatosVerificarAuth.java
│   ├── cajero/
│   │   ├── Cajero.java
│   │   ├── dto/
│   │   │   ├── DatosDetalleCajero.java
│   │   │   ├── DatosListaCajero.java
│   │   │   ├── DatosListaCajeros.java
│   │   │   └── DatosRegistroCajero.java
│   │   └── mapper/
│   │       └── CajeroMapper.java
│   ├── enlace/
│   │   ├── Invitacion.java
│   │   └── dto/
│   │       ├── DatosInvitacion.java
│   │       ├── DatosRespuestaEnlace.java
│   │       ├── DatosSolicitudEnlace.java
│   │       └── DatosSolicitudInvitacion.java
│   ├── negocio/
│   │   ├── Negocio.java
│   │   ├── dto/
│   │   │   ├── DatosDetalleNegocio.java
│   │   │   └── DatosRegistroNegocio.java
│   │   └── mapper/
│   │       └── NegocioMapper.java
│   └── producto/
│       ├── Producto.java
│       ├── dto/
│       │   ├── DatosDetalleProducto.java
│       │   └── DatosRegistroProducto.java
│       └── mapper/
│           └── ProductoMapper.java
├── repository/
│   ├── AdministradorRepository.java
│   ├── CajeroRepository.java
│   ├── InvitacionRepository.java
│   ├── NegocioRepository.java
│   └── ProductoRepository.java
└── services/
    ├── AuthService.java
    ├── EnlaceService.java
    ├── NegocioService.java
    └── ProductoService.java
```

### Cambios vs v1:
- **Eliminado:** `service/api/`, `config/`, `domain/usuario/` (tabla única), `domain/admin/` (soporte), `AdminService`, `AdminController`, `AutorizacionService`, `AutorizacionController`, `UsuarioHelper`, `UsuarioRepository`, `RolUsuario`
- **Agregado:** `domain/auth/dto/` con DTOs unificados, `DatosListaCajeros` wrapper, helpers específicos por entidad

---

## 3. Convenciones de Código

### 3.1 Idioma
- **Clases, métodos, variables, DTOs:** Español (`verificarUsuario`, `registrarNegocio`, `DatosVerificarAuth`)
- **URLs en endpoints:** Inglés (`/api/v1/auth/verificar`, `/api/v1/business`)
- **Excepciones:** Español (`NoExisteException`, `YaRegistradoException`)

### 3.2 Controller (máximo 4 líneas)
Cada método del controller hace solo 4 cosas:
1. Recibir el request (parámetros/body)
2. Llamar al service
3. Construir URI (si aplica POST)
4. Retornar `ResponseEntity`

### 3.3 DTOs
- **Records de Java** (inmutables)
- `@JsonProperty` para sincronizar nombres del JSON del contrato con los nombres Java
- Ej: `@JsonProperty("queVende") String giro`, `@JsonProperty("horario") String horarioCierre`

### 3.4 Entidades
- **Lombok `@Data`** (getters, setters, toString, equals, hashCode)
- `@NoArgsConstructor` + `@AllArgsConstructor`
- `@PrePersist` para `registro` (created_at)
- IDs: `UUID` con `GenerationType.UUID`
- Dinero: `BigDecimal` (escala 2)

### 3.5 Mappers
- **MapStruct** con `componentModel = "spring"`
- Sin interfaces de Service (solo clases concretas)

### 3.6 Helpers
- Validan IDs: `validarIdNegocio(String id)`, `validarIdAdministrador(String id)`, etc.
- Validan unicidad: `negocioYaRegistrado(String nombre)`, `validarGoogleNoRegistrado(String idGoogle)`
- Lanzan `NoExisteException` (404) si no existe, `YaRegistradoException` (409) si ya existe

### 3.7 Excepciones Personalizadas

| Excepción | HTTP Status | Uso |
|-----------|-------------|-----|
| `NoExisteException` | 404 | Entidad no encontrada |
| `NoAutenticadoException` | 401 | Token inválido/expirado |
| `NoAutorizadoException` | 403 | Sin permisos |
| `YaExisteException` | 409 | Google ID ya registrado |
| `YaRegistradoException` | 409 | Recurso duplicado |
| `DuplicadoException` | 409 | Violación de unicidad |

### 3.8 GlobalExceptionHandler
Captura todas las excepciones y devuelve:
```json
{
  "codigo": "NO_EXISTE",
  "mensaje": "Negocio no encontrado",
  "ubicacion": "NegocioService.obtenerDetalle",
  "status": 404
}
```

---

## 4. Tablas Separadas por Rol (Decisión Crítica)

En lugar de una tabla única `usuarios` con columna `rol`, se usan **tres tablas independientes**:

| Tabla | Propósito |
|-------|-----------|
| `negocios` | Datos del negocio |
| `administradores` | Dueños/administradores del negocio |
| `cajeros` | Empleados cajeros |

### Razones:
- **Eficiencia:** Las consultas de auth son más rápidas en tablas más pequeñas (busca admin primero ~20k regs, después cajero ~100k regs)
- **Escalabilidad:** 500k productos, 20k admins, 100k cajeros — tablas separadas evitan cuellos de botella
- **Dominios diferentes:** Admin tiene plan/licencia, Cajero tiene permisos — campos distintos

### Flujo de Auth:
```
GET /api/v1/auth/verificar/{idGoogle}
1. Buscar en administradores
   ├── Existe → return dueño
   └── No existe → paso 2
2. Buscar en cajeros
   ├── Existe → return cajero
   └── No existe → return 404 { existe: false, codigo: "NO_REGISTRADO" }
```

---

## 5. Seguridad (Fase I)

- **Sin JWT aún:** Token base64 placeholder `userId:timestamp` encodeado
- **Sin Spring Security:** No hay filtros de autenticación todavía
- **Plan futuro:** JWT con Spring Security, sesión de 12 horas, SecureStorage en Flutter

---

## 6. Persistencia

- **Flyway** para migraciones de esquema
- **JPA `ddl-auto: update`** para desarrollo (refleja cambios de entidades)
- **H2** en desarrollo, **PostgreSQL** en producción
