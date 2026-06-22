# Flujo de Desarrollo — Taco'Os v0.2 (Fase I)

> **Equipo:**
> - **Jesús Medina** — Backend (Spring Boot)
> - **Fanner** — Flutter + UI
> - **Leandro** — Data Science (Fase III+)

---

## Filosofía de Construcción

1 pieza a la vez. Cada pieza se compila y se entiende antes de pasar a la siguiente.
El dueño del proyecto (tú) decides nombres, estructura y orden.
**Tu palabra es la prioridad, no lo que el código sugiere.**
Construcción ascendente: desde auth hacia negocio, pieza por pieza. Cada pieza la revisas personalmente antes de avanzar.

---

## Criterios de Completitud (Definition of Done)

### B — Autenticación
- [x] `GET /api/v1/auth/verificar/{idGoogle}` — busca admin, luego cajero, si no → 404 específico
- [x] `POST /api/v1/auth/registrar` — endpoint único con campo `rol: "dueño"/"cajero"`
- [x] Token base64 placeholder (userId:timestamp)
- [x] Response incluye `tieneNegocio`, `negocioId`, `negocioNombre`
- [x] Helper valida Google ID duplicado antes de registrar

### C — Negocios (Dueño)
- [x] `POST /api/v1/business` — crea negocio + asigna dueño
- [x] `GET /api/v1/business/{id}` — detalle del negocio
- [x] `PUT /api/v1/business/{id}` — editar negocio
- [x] `GET /api/v1/business/{id}/cajeros` — lista de cajeros enlazados

### D — Enlace Cajero (QR Handshake)
- [x] `POST /api/v1/business/invitation` — genera código de invitación temporal
- [x] `POST /api/v1/business/link` — enlaza cajero al negocio
- [x] Cajero se enlaza con `usuarioId` (no crea nuevo usuario)
- [x] Invitación expira en 15 minutos

### Productos (Pendiente)
- [x] `POST /api/v1/business/{id}/products` — crear producto
- [x] `GET /api/v1/business/{id}/products` — listar por categoría
- [x] `PUT /api/v1/business/{id}/products/{id}` — editar
- [x] `DELETE /api/v1/business/{id}/products/{id}` — eliminar

### Sesiones y Transacciones (Pendiente)
- [x] `POST /api/v1/cashier/open-session` — apertura de caja
- [x] `POST /api/v1/transactions` — venta/gasto
- [x] `POST /api/v1/cashier/close-session` — corte de caja
- [x] `POST /api/v1/transactions/{id}/cancel` — cancelación con foto

### Sincronización (Pendiente)
- [x] `POST /api/v1/sync` — batch cada 5 min

### Reportes y Notificaciones (Pendiente)
- [x] Reportes: Cajas Abiertas, Cortes, Estadísticas
- [x] Notificaciones: GET, DELETE
- [x] Licencias: Planes, Upgrade, Trial

---

## Convenciones de Implementación

### Controller (máximo 4 líneas)
```java
@PostMapping
public ResponseEntity<DatosDetalleNegocio> registrar(@RequestBody DatosRegistroNegocio datos,
                                                      @RequestParam String duenoId,
                                                      UriComponentsBuilder ucb) {
    var negocio = negocioService.registrarNegocio(datos, duenoId);
    var uri = ucb.path("/api/v1/business/{id}").buildAndExpand(negocio.id()).toUri();
    return ResponseEntity.created(uri).body(negocio);
}
```

### Service (sin interfaz)
```java
@Service
@RequiredArgsConstructor
public class NegocioService {
    private final NegocioRepository negocioRepository;
    // métodos con @Transactional
}
```

### Helper valida antes de operar
```java
public class NegocioHelper {
    public Negocio validarIdNegocio(String id) {
        // valida null, UUID inválido, existencia → lanza NoExisteException
    }
    public void negocioYaRegistrado(String nombre) {
        // verifica unicidad → lanza YaRegistradoException
    }
}
```

### DTOs con @JsonProperty
```java
public record DatosRegistroNegocio(
    String nombre,
    String direccion,
    String telefono,
    @JsonProperty("queVende") String giro,
    Integer empleados,
    @JsonProperty("horario") String horarioCierre
) {}
```

---

## Asignación de Tareas

| Área | Jesús (Backend) | Fanner (Flutter) | Leandro (DS) |
|------|----------------|-------------------|--------------|
| Auth + Sesión | Endpoints verificar/registrar, token base64 | Google Sign-In, manejo de sesión | — |
| Onboarding QR | Invitación, enlace, validación licencia | Cámara QR, UI onboarding | — |
| Negocios | CRUD negocio, asignación dueño | Vista "Registrar tu negocio" | — |
| Catálogo | CRUD productos, categorías fijas | Lista, popup, teclado numérico | Validar esquema |
| Transacciones | Endpoint universal, validación 5 min | Flujo cobro, cámara baucher | — |
| Corte | Apertura/cierre sesión, auto-cierre | UI corte, conteo, ticket | — |
| Sync | Batch endpoint, resolución conflictos | Worker 5 min, SQLite local | Esquemas |
| Reportes | Cajas abiertas, cortes, estadísticas | UI reportes, filtros | — |
| Notificaciones | CRUD, tipos | Campanita 🔔, historial | — |
| Licencias | Planes, trial, validación límites | UI dashboard licencia, upsell | — |

---

## Historial de Cambios

| Fecha | Cambio |
|-------|--------|
| 2026-06-18 | v0.2 — Refactor completo: package `com.jmcsoft.taco_os`, tablas separadas, auth unificado, @JsonProperty, endpoints en inglés, eliminación de legacy |
