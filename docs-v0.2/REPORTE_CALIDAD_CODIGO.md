# Reporte de Calidad de Código — Taco'Os

> Auditoría completa del proyecto (Backend + Frontend).
> Generado: 2026-06-21
> **40+ issues encontrados** en 7 categorías.

---

## Índice

| Categoría | Severidad | Cantidad |
|-----------|-----------|----------|
| [1. Seguridad](#1-seguridad) | 🔴 Crítica | 7 |
| [2. Lógica Irregular / Sin Terminar](#2-lógica-irregular--sin-terminar) | 🔴 Alta | 12 |
| [3. Redundancias](#3-redundancias) | 🟡 Media | 9 |
| [4. Inconsistencias](#4-inconsistencias) | 🟡 Media | 10 |
| [5. Sin Validaciones](#5-sin-validaciones) | 🟠 Alta | 8 |
| [6. Frontend — Problemas Críticos](#6-frontend--problemas-críticos) | 🔴 Alta | 8 |
| [7. Frontend — Anti-patrones Angular](#7-frontend--anti-patrones-angular) | 🟡 Media | 7 |

---

## 1. SEGURIDAD

### 1.1 JWT Secret hardcodeado en el repo

- **Archivo:** `backend/src/main/resources/application-dev.yml:31`
- **Problema:** El secret de JWT está en texto plano: `TacoOs2025SecretKeyForJwtTokenGenerationAndValidationP455w0rd`
- **Riesgo:** Cualquiera con acceso al repo puede forjar tokens JWT válidos.
- **Fix:**
  ```yaml
  # Mover a variable de entorno
  jwt:
    secret: ${JWT_SECRET:TacoOs2025SecretKeyForJwtTokenGenerationAndValidationP455w0rd}
  ```
  En producción: usar variables de entorno, nunca commitear secrets.

---

### 1.2 Passwords sin hash — comparación en texto plano

- **Archivo:** `backend/src/main/java/.../services/SuperSuService.java:44`
  ```java
  superUser.getPasswordHash().equals(datos.password())
  ```
- **Archivo:** `backend/src/main/java/.../services/master/MasterAuthService.java:33`
  ```java
  user.getPasswordHash().equals(datos.password())
  ```
- **Archivo:** `backend/src/main/java/.../services/master/MasterTeamService.java:49`
  ```java
  user.setPasswordHash(datos.password())
  ```
- **Problema:** Contraseñas almacenadas y comparadas en texto plano. Sin `PasswordEncoder`.
- **Fix:**
  1. Agregar `BCryptPasswordEncoder` como bean en SecurityConfig
  2. Hashear passwords al crear usuario: `passwordEncoder.encode(password)`
  3. Comparar con: `passwordEncoder.matches(rawPassword, hashedPassword)`
  4. Actualizar seed data con passwords hasheados

---

### 1.3 H2 Console accesible sin autenticación

- **Archivo:** `backend/src/main/java/.../config/SecurityConfig.java:52-55`
  ```java
  .requestMatchers("/h2-console/**").permitAll()
  ```
- **Problema:** Acceso directo a la base de datos desde el browser sin login.
- **Fix:** Deshabilitar en producción, o agregar autenticación básica:
  ```java
  .requestMatchers("/h2-console/**").hasRole("DEVELOPER")
  ```

---

### 1.4 WebSocket sin autenticación

- **Archivo:** `backend/src/main/java/.../config/WebSocketConfig.java:20-23`
- **Problema:** El endpoint STOMP `/ws/chat` no tiene configuración de seguridad. Cualquiera puede conectarse.
- **Fix:** Agregar interceptor de autenticación STOMP:
  ```java
  @Override
  void registerStompEndpoints(StompEndpointRegistry registry) {
      registry.addEndpoint("/ws/chat")
          .setAllowedOrigins("http://localhost:4200")
          .addInterceptors(new HttpSessionHandshakeInterceptor());
  }
  ```

---

### 1.5 Passwords en Swagger/OpenAPI

- **Archivo:** `backend/src/main/java/.../domain/master/user/dto/DatosLoginMaster.java:9`
  ```java
  @Schema(description = "Password", example = "dev123")
  ```
- **Archivo:** `backend/src/main/java/.../domain/auth/dto/DatosLoginSuperSu.java:11`
  ```java
  @Schema(description = "Password", example = "AdminSu")
  ```
- **Problema:** Ejemplos de passwords visibles en Swagger UI.
- **Fix:**
  ```java
  @Schema(description = "Password", example = "****", accessMode = AccessMode.WRITE_ONLY)
  ```

---

### 1.6 CORS permite todos los headers

- **Archivo:** `backend/src/main/java/.../config/SecurityConfig.java:65`
  ```java
  config.setAllowedHeaders(List.of("*"))
  ```
- **Problema:** Si se relaja la restricción de origins, cualquier header es permitido.
- **Fix:** Especificar headers explícitos:
  ```java
  config.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With"))
  ```

---

### 1.7 Sin rate limiting en endpoints de auth

- **Endpoints afectados:** `/api/v1/super-su/login`, `/api/v1/master/auth/login`, `/api/v1/auth/registrar`
- **Problema:** Sin protección contra ataques de fuerza bruta.
- **Fix:** Implementar rate limiting con bucket4j o spring-rate-limiter:
  ```java
  // Ejemplo con interceptor
  @Override
  public boolean preHandle(HttpServletRequest request, ...) {
      String ip = request.getRemoteAddr();
      if (rateLimiter.tryConsume(ip)) return true;
      throw new TooManyRequestsException();
  }
  ```

---

## 2. LÓGICA IRREGULAR / SIN TERMINAR

### 2.1 MasterOperationsService no ejecuta operaciones reales

- **Archivo:** `backend/src/main/java/.../services/master/MasterOperationsService.java:21-58`
- **Problema:** Los 3 métodos (`forzarCierreSesion`, `ajustarSaldo`, `bloquearUsuario`) solo escriben audit log pero **nunca ejecutan** la operación real.
- **Fix:**
  ```java
  public void forzarCierreSesion(DatosForzarCierre datos) {
      // 1. Buscar sesión activa del cajero
      SesionCajero sesion = sesionRepo.findByCajeroIdAndEstado(datos.cajeroId(), EstadoSesion.ABIERTA)
          .orElseThrow(() -> new NoExisteException("Sesión no encontrada"));
      // 2. Cerrar la sesión
      sesion.setEstado(EstadoSesion.CERRADA);
      sesion.setCierre(LocalDateTime.now());
      sesionRepo.save(sesion);
      // 3. Registrar en audit log
      auditLogRepo.save(...);
  }
  ```

---

### 2.2 SyncService no sincroniza datos

- **Archivo:** `backend/src/main/java/.../services/SyncService.java:13-32`
- **Problema:** Solo cuenta items en el payload y retorna success. No hay sincronización real.
- **Fix:** Implementar lógica de sync:
  ```java
  public DatosRespuestaSync sincronizarBatch(DatosSincronizacion datos) {
      int procesados = 0;
      int fallidos = 0;
      for (var transaccion : datos.transacciones()) {
          try {
              transaccionRepo.save(transaccion);
              procesados++;
          } catch (Exception e) {
              fallidos++;
              log.error("Error sincronizando transacción: {}", transaccion.id(), e);
          }
      }
      return new DatosRespuestaSync(procesados, fallidos, LocalDateTime.now());
  }
  ```

---

### 2.3 ReporteService retorna datos hardcodeados

- **Archivo:** `backend/src/main/java/.../services/ReporteService.java:39-43`
- **Problema:** `cajasAbiertas()` siempre retorna `transaction_count: 0`, `total_sales: 0`, `total_expenses: 0`.
- **Fix:** Consultar transacciones reales:
  ```java
  public List<DatosCajaAbierta> cajasAbiertas(String negocioId) {
      return sesionRepo.findByNegocioIdAndEstado(negocioId, EstadoSesion.ABIERTA)
          .stream()
          .map(sesion -> {
              var stats = transaccionRepo.sumBySesionId(sesion.getId());
              return new DatosCajaAbierta(sesion, stats);
          })
          .toList();
  }
  ```

---

### 2.4 ReporteController retorna datos hardcodeados

- **Archivo:** `backend/src/main/java/.../controller/ReporteController.java:28-49`
- **Problema:** `estadisticas()` retorna ceros hardcodeados con fecha estática `"2026-06-01"`.
- **Fix:** Delegar al service y usar datos reales.

---

### 2.5 LicenciaService retorna features hardcodeadas

- **Archivo:** `backend/src/main/java/.../services/LicenciaService.java:69`
  ```java
  return List.of("basic_reports", "cashier_management");
  ```
- **Problema:** Siempre retorna las mismas features sin importar el plan.
- **Fix:**
  ```java
  return switch (plan) {
      case FREE -> List.of("basic_reports", "cashier_management", "weekly_ai_advice");
      case PREMIUM -> List.of("basic_reports", "detailed_reports", "cashier_management", "multiple_branches", "limited_ai");
      case BUSINESS -> List.of("basic_reports", "detailed_reports", "cashier_management", "multiple_branches", "ai_insights");
  };
  ```

---

### 2.6 MasterDashboardService con stats parciales

- **Archivo:** `backend/src/main/java/.../services/master/MasterDashboardService.java:51`
  ```java
  0, 0  // totalClientesInactivos, sesionesAbiertas
  ```
- **Problema:** Pasa ceros en vez de datos reales.
- **Fix:** Consultar:
  ```java
  long clientesInactivos = administradorRepo.countByActivoFalse();
  long sesionesAbiertas = sesionRepo.countByEstado(EstadoSesion.ABIERTA);
  ```

---

### 2.7 DailyCut no valida sesión abierta

- **Archivo:** `backend/src/main/java/.../services/DailyCutService.java:42-103`
- **Problema:** Acepta cualquier sesión por ID sin verificar que esté ABIERTA.
- **Fix:**
  ```java
  if (sesion.getEstado() != EstadoSesion.ABIERTA) {
      throw new IllegalStateException("Solo se pueden cerrar sesiones abiertas");
  }
  ```

---

### 2.8 Transacciones permiten sesión cerrada

- **Archivo:** `backend/src/main/java/.../services/TransaccionService.java:43-70`
- **Problema:** No valida que la sesión esté ABIERTA al registrar transacciones.
- **Fix:**
  ```java
  SesionCajero sesion = sesionRepo.findById(sesionId)
      .orElseThrow(() -> new NoExisteException("Sesión no encontrada"));
  if (sesion.getEstado() != EstadoSesion.ABIERTA) {
      throw new IllegalStateException("La sesión no está abierta");
  }
  ```

---

### 2.9 MasterClientService cuenta cajeros globales

- **Archivo:** `backend/src/main/java/.../services/master/MasterClientService.java:44`
  ```java
  long cajeros = cajeroRepository.count();
  ```
- **Problema:** Cuenta TODOS los cajeros del sistema, no los del negocio específico.
- **Fix:**
  ```java
  long cajeros = cajeroRepository.countByNegocioId(cliente.getNegocio().getId());
  ```

---

### 2.10 LicenciaService permite downgrade

- **Archivo:** `backend/src/main/java/.../services/LicenciaService.java:73-98`
- **Problema:** `mejorarPlan()` no valida que el plan nuevo sea realmente un upgrade.
- **Fix:**
  ```java
  if (nuevoPlan.ordinal() <= admin.getTipoPlan().ordinal()) {
      throw new IllegalStateException("Solo se pueden mejorar planes, no downgrade");
  }
  ```

---

### 2.11 NPE en activarTrial

- **Archivo:** `backend/src/main/java/.../controller/LicenciaController.java:37`
  ```java
  String plan = body.get("plan");
  licenciaService.activarTrial(negocioId, plan); // plan puede ser null → NPE
  ```
- **Fix:**
  ```java
  String plan = body.get("plan");
  if (plan == null || plan.isBlank()) {
      throw new IllegalArgumentException("El campo 'plan' es requerido");
  }
  ```

---

### 2.12 Invitaciones expiradas siguen activas

- **Archivo:** `backend/src/main/java/.../repository/InvitacionRepository.java`
  ```java
  Optional<Invitacion> findByCodigoAndActivoTrue(String codigo);
  ```
- **Problema:** Solo valida `is_active`, no `expires_at`.
- **Fix:**
  ```java
  Optional<Invitacion> findByCodigoAndActivoTrueAndExpiraEnAfter(
      String codigo, LocalDateTime ahora);
  ```

---

## 3. REDUNDANCIAS

### 3.1 Tres excepciones idénticas

- **Archivos:**
  - `DuplicadoException.java`
  - `YaExisteException.java`
  - `YaRegistradoException.java`
- **Problema:** Misma estructura (4 campos), mismo HTTP status (409), solo cambia el `codigo`.
- **Fix:** Consolidar en una sola:
  ```java
  public class ConflictException extends RuntimeException {
      private final String codigo;
      private final String mensaje;
      private final String ubicacion;
      private final int statusHttp;

      public ConflictException(String codigo, String mensaje, String ubicacion) {
          super(mensaje);
          this.codigo = codigo;
          this.mensaje = mensaje;
          this.ubicacion = ubicacion;
          this.statusHttp = 409;
      }
  }
  ```

---

### 3.2 Tres helpers con validarId idéntico

- **Archivos:** `NegocioHelper.java`, `CajeroHelper.java`, `AdministradorHelper.java`
- **Problema:** `validarId*()` es copia-pega del mismo patrón.
- **Fix:** Extraer a un helper genérico:
  ```java
  @Component
  public class EntityHelper {
      public <T> T validarId(UUID id, JpaRepository<T, UUID> repo, String entidad) {
          if (id == null) throw new IllegalArgumentException("ID no puede ser null");
          return repo.findById(id)
              .orElseThrow(() -> new NoExisteException(entidad + " no encontrado"));
      }
  }
  ```

---

### 3.3 Auth duplica lógica admin/cajero

- **Archivo:** `backend/src/main/java/.../services/AuthService.java:26-65, 67-118`
- **Problema:** `verificarUsuario()` y `registrar()` tienen 2 branches casi idénticos.
- **Fix:** Extraer método genérico:
  ```java
  private <T> DatosUsuarioAuth construirDatosUsuario(T user, String rol, String negocioId) {
      // lógica común
  }
  ```

---

### 3.4 ValidarGoogleNoRegistrado nunca se usa

- **Archivos:** `AdministradorHelper.java:15`, `CajeroHelper.java:15`
- **Problema:** Métodos definidos pero nunca llamados.
- **Fix:** Eliminar ambos métodos.

---

### 3.5 toggleActivo duplicado

- **Archivos:** `MasterClientService.java:67-73`, `MasterTeamService.java:58-64`
- **Problema:** Mismo patrón toggle-boolean-and-save.
- **Fix:** Extraer a método genérico en un util o base service.

---

### 3.6 Switch-case de planes duplicado

- **Archivo:** `backend/src/main/java/.../services/LicenciaService.java:85-98, 122-132`
- **Problema:** `mejorarPlan()` y `activarTrial()` repiten el switch de maxNegocios/maxCajeros.
- **Fix:** Extraer a método privado:
  ```java
  private void aplicarLimitesPlan(TipoPlan plan, Administrador admin) {
      switch (plan) {
          case FREE -> { admin.setMaxNegocios(1); admin.setMaxCajeros(2); }
          case PREMIUM -> { admin.setMaxNegocios(2); admin.setMaxCajeros(5); }
          case BUSINESS -> { admin.setMaxNegocios(5); admin.setMaxCajeros(25); }
      }
  }
  ```

---

### 3.7 SuperSuService ejecuta queries 2 veces

- **Archivo:** `backend/src/main/java/.../services/SuperSuService.java:105-119`
- **Problema:** Líneas 107-111 ejecutan 4 queries, líneas 113-118 ejecutan las mismas 4 queries.
- **Fix:** Eliminar las primeras queries o reutilizar las variables.

---

### 3.8 CommonModule innecesario en Angular 21

- **Archivos:** Todos los page components
- **Problema:** Angular 21 con `@if`/`@for` no necesita `CommonModule`.
- **Fix:** Eliminar `CommonModule` de imports, usar `DatePipe` directamente donde se necesita.

---

### 3.9 getStatusClass() duplicado

- **Archivos:** `tickets.component.ts:79-86`, `ticket-detail.component.ts:102-109`
- **Problema:** Método idéntico copiado.
- **Fix:** Extraer a `src/app/shared/utils.ts`:
  ```typescript
  export function getStatusBadgeClass(status: string, map: Record<string, string>): string {
      return map[status] || 'bg-gray-100 text-gray-800';
  }
  ```

---

## 4. INCONSISTENCIAS

### 4.1 negociosController con `n` minúscula

- **Archivo:** `backend/src/main/java/.../controller/negociosController.java:15`
- **Problema:** Viola convención Java PascalCase.
- **Fix:** Renombrar a `NegociosController.java`.

---

### 4.2 Mezcla español/inglés en packages master

- **Problema:** `domain.master.ticket` (inglés) vs `domain.corte` (español).
- **Fix:** Estandarizar. Opciones:
  - Todo en español: `domain/master/ticket` → `domain/master/boleto`
  - Todo en inglés: `domain/corte` → `domain/dailycut`
  - Recomendado: mantener español en dominio principal, inglés en master (ya está así).

---

### 4.3 Inconsistencia en colecciones terminales

- **Archivos:**
  - `NegocioService.java:76`: `.collect(Collectors.toList())`
  - `SuperSuService.java:70`: `.toList()`
- **Fix:** Estandarizar a `.toList()` (Java 16+).

---

### 4.4 UUID validation lanza excepciones diferentes

- **Problema:** `NegocioHelper` lanza `IllegalArgumentException`, `ProductoHelper` lanza `NoExisteException` para el mismo error.
- **Fix:** Estandarizar a `NoExisteException` con mensaje descriptivo.

---

### 4.5 Token expiration units inconsistentes

- **Archivos:**
  - `AuthService.java:44`: `/ 3600000` → horas
  - `SuperSuService.java:60`: `/ 1000` → segundos
- **Fix:** Estandarizar a segundos en todos lados.

---

### 4.6 SuperSuController retorna JSON raw

- **Archivo:** `backend/src/main/java/.../controller/SuperSuController.java:46,53`
  ```java
  return ResponseEntity.ok("{\"mensaje\":\"Administrador activado\"}");
  ```
- **Fix:** Usar DTO:
  ```java
  return ResponseEntity.ok(new DatosRespuestaSimple("Administrador activado"));
  ```

---

### 4.7 2 controllers mismo base path

- **Archivos:** `DailyCutController.java` y `CashierSessionController.java` ambos usan `/api/v1/cashier`
- **Fix:** Separar paths:
  ```java
  // DailyCutController
  @RequestMapping("/api/v1/daily-cut")
  // CashierSessionController
  @RequestMapping("/api/v1/cashier")
  ```

---

### 4.8 URLs hardcodeadas en 2 services frontend

- **Archivos:**
  - `auth.service.ts:14`: `private readonly API = 'http://localhost:8080/api/v1/master/auth'`
  - `api.service.ts:7`: `private readonly BASE = 'http://localhost:8080/api/v1/master'`
- **Fix:** Crear `src/environments/environment.ts`:
  ```typescript
  export const environment = {
      apiUrl: 'http://localhost:8080/api/v1/master'
  };
  ```

---

### 4.9 Inconsistencia standalone: true

- **Problema:** Angular 21 default es standalone, pero algunos components lo declaran explícitamente y otros no.
- **Fix:** Eliminar `standalone: true` de todos (es el default en Angular 21).

---

### 4.10 Inconsistencia constructor injection

- **Archivo:** `layout.component.ts:60`: `constructor(public auth: AuthService)`
- **Todos los demás:** `constructor(private ...)`
- **Fix:** Cambiar a `private` y exposer via getter o propiedad.

---

## 5. SIN VALIDACIONES

### 5.1 Sin @Valid en ningún DTO

- **Problema:** Ningún controller tiene `@Valid` en `@RequestBody`. Ningún DTO tiene anotaciones Jakarta Validation.
- **Fix:** Agregar validaciones:
  ```java
  public record DatosRegistroNegocio(
      @NotBlank @Size(min = 3, max = 100) String nombre,
      @NotBlank String direccion,
      @NotBlank String telefono
  ) {}
  ```
  Y en controller:
  ```java
  public ResponseEntity<?> registrar(@Valid @RequestBody DatosRegistroNegocio datos, ...) {
  ```

---

### 5.2 Sin validación de ownership multi-tenant

- **Problema:** Cualquier usuario autenticado puede operar en cualquier negocio.
- **Fix:** Agregar validación en cada service:
  ```java
  private void validarPropiedad(String negocioId, Authentication auth) {
      String userId = auth.getName();
      if (!negocioRepo.existsByIdAndDuenoId(negocioId, UUID.fromString(userId))) {
          throw new NoAutorizadoException("No tienes acceso a este negocio");
      }
  }
  ```

---

### 5.3 Sin validación de producto-pertenencia

- **Archivo:** `ProductoService.java:59-71, 73-80`
- **Problema:** Valida que negocio y producto existen, pero no que el producto pertenece al negocio.
- **Fix:**
  ```java
  if (!producto.getNegocio().getId().equals(negocioId)) {
      throw new NoAutorizadoException("El producto no pertenece a este negocio");
  }
  ```

---

### 5.4 Sin validación de notificación-pertenencia

- **Archivo:** `NotificacionService.java:37-48`
- **Problema:** Valida que negocio existe, pero no que la notificación le pertenece.
- **Fix:** Agregar join en query o validación manual.

---

### 5.5 Sin validación en transacciones

- **Archivo:** `TransaccionController.java:19-23`
- **Problema:** No valida que `total > 0`, `tipo` sea enum válido, `pago` consistente.
- **Fix:** Agregar validaciones Jakarta en DTO.

---

### 5.6 Sin validación en cancelación

- **Archivo:** `TransaccionService.java:72-107`
- **Problema:** No valida ownership — cualquier usuario puede cancelar cualquier transacción.
- **Fix:** Validar que el usuario autenticado es el cajero que creó la transacción.

---

### 5.7 SyncController acepta Map sin validación

- **Archivo:** `SyncController.java:18`
- **Problema:** Acepta `Map<String, Object>` sin validar estructura.
- **Fix:** Usar DTO tipado.

---

### 5.8 Ticket status acepta cualquier string

- **Archivo:** `MasterTicketService.java:72-81`
- **Problema:** No valida que `nuevoEstado` sea un valor válido del enum.
- **Fix:**
  ```java
  private static final Set<String> ESTADOS_VALIDOS = Set.of("ABIERTO", "EN_PROGRESO", "RESUELTO", "CERRADO");

  public void cambiarEstado(String id, String nuevoEstado) {
      if (!ESTADOS_VALIDOS.contains(nuevoEstado)) {
          throw new IllegalArgumentException("Estado inválido: " + nuevoEstado);
      }
      // ...
  }
  ```

---

## 6. FRONTEND — PROBLEMAS CRÍTICOS

### 6.1 `any` en todo el proyecto (sin tipos)

- **Archivos:** Todos los components y services
- **Problema:** `strict: true` en tsconfig pero todo usa `any`. Cero interfaces definidas.
- **Fix:** Crear modelos en `src/app/core/models/`:
  ```typescript
  // client.model.ts
  export interface Client {
      id: string;
      nombreCompleto: string;
      correo: string;
      negocioNombre: string;
      plan: string;
      activo: boolean;
  }

  // ticket.model.ts
  export interface Ticket {
      id: string;
      titulo: string;
      prioridad: 'URGENTE' | 'ALTO' | 'NORMAL' | 'BAJO';
      estado: 'ABIERTO' | 'EN_PROGRESO' | 'RESUELTO' | 'CERRADO';
      clienteNombre: string;
      creadoEl: string;
  }
  ```
  Y reemplazar todos los `any` con los tipos correspondientes.

---

### 6.2 Token expiration ignorado

- **Archivo:** `control-master/src/app/core/auth.service.ts:44-46`
  ```typescript
  isAuthenticated(): boolean {
      return !!this.getToken(); // No valida expiración
  }
  ```
- **Problema:** El campo `vencimiento` viene del backend pero nunca se almacena ni valida.
- **Fix:**
  ```typescript
  login(credentials: {username: string, password: string}): Observable<LoginResponse> {
      return this.http.post<LoginResponse>(this.API + '/login', credentials).pipe(
          tap(res => {
              localStorage.setItem('token', res.token);
              localStorage.setItem('vencimiento', res.vencimiento.toString());
              localStorage.setItem('usuario', JSON.stringify(res.usuario));
          })
      );
  }

  isAuthenticated(): boolean {
      const token = this.getToken();
      const vencimiento = localStorage.getItem('vencimiento');
      if (!token || !vencimiento) return false;
      return Date.now() < parseInt(vencimiento, 10);
  }
  ```

---

### 6.3 13/17 subscriptions sin error handling

- **Archivos:** Dashboard, Clients, ClientDetail, Tickets, TicketDetail, Team, Billing components
- **Problema:** Errores HTTP silenciados — pantalla blanca sin feedback.
- **Fix:** Agregar manejo de errores:
  ```typescript
  this.api.getClients().subscribe({
      next: (data) => this.clients = data,
      error: (err) => {
          console.error('Error loading clients', err);
          this.error = 'Error al cargar clientes';
      }
  });
  ```

---

### 6.4 Optimistic UI sin rollback

- **Archivos:** `client-detail.component.ts:71-74`, `team.component.ts:67-70`
- **Problema:** Si el API falla, el UI muestra estado incorrecto.
- **Fix:**
  ```typescript
  toggleClient() {
      const previous = this.client.activo;
      this.client.activo = !this.client.activo; // Optimistic
      this.api.toggleClient(this.client.id).subscribe({
          error: () => {
              this.client.activo = previous; // Rollback
              this.message = 'Error al cambiar estado';
          }
      });
  }
  ```

---

### 6.5 Operaciones destructivas sin confirmación

- **Archivo:** `control-master/src/app/pages/operations/operations.component.ts`
- **Problema:** Botón "Ejecutar" ejecuta force-close, adjust-balance, block-user sin confirmación.
- **Fix:** Agregar MatDialog:
  ```typescript
  onForceClose() {
      const dialogRef = this.dialog.open(ConfirmDialogComponent, {
          data: { titulo: 'Forzar cierre de sesión', mensaje: '¿Estás seguro?' }
      });
      dialogRef.afterConfirmed().subscribe(() => {
          this.api.forceCloseSession(this.operationData).subscribe({...});
      });
  }
  ```

---

### 6.6 Detail pages sin loading/error states

- **Archivos:** `client-detail.component.ts`, `ticket-detail.component.ts`
- **Problema:** Pantalla blanca mientras carga, sin error si falla.
- **Fix:**
  ```html
  @if (loading) {
      <mat-progress-bar mode="indeterminate"></mat-progress-bar>
  } @else if (error) {
      <div class="text-red-600 p-4">{{ error }}</div>
  } @else if (client) {
      <!-- contenido -->
  }
  ```

---

### 6.7 vencimiento nunca se guarda

- **Archivo:** `control-master/src/app/core/auth.service.ts:22-25`
  ```typescript
  login(credentials) {
      return this.http.post<LoginResponse>(this.API + '/login', credentials).pipe(
          tap(res => {
              localStorage.setItem('token', res.token);
              localStorage.setItem('usuario', JSON.stringify(res.usuario));
              // res.vencimiento NO se guarda
          })
      );
  }
  ```
- **Fix:** Agregar `localStorage.setItem('vencimiento', res.vencimiento.toString());`

---

### 6.8 Formularios sin validación

- **Archivos:** Login, Operations components
- **Problema:** Login usa `required` HTML pero sin Angular form validation. Operations no tiene ninguna validación.
- **Fix:** Usar Angular Reactive Forms:
  ```typescript
  this.form = this.fb.group({
      cajeroId: ['', Validators.required],
      sesionId: ['', Validators.required]
  });
  ```

---

## 7. FRONTEND — ANTI-PATRONES ANGULAR

### 7.1 Sin limpieza de subscriptions

- **Problema:** 17 llamadas `subscribe()`, 0 implementan `OnDestroy` o `takeUntilDestroyed`.
- **Fix:** Usar `DestroyRef`:
  ```typescript
  constructor(private destroyRef: DestroyRef) {}

  ngOnInit() {
      this.api.getClients().pipe(
          takeUntilDestroyed(this.destroyRef)
      ).subscribe(data => this.clients = data);
  }
  ```

---

### 7.2 Sin OnPush change detection

- **Problema:** Todos los components usan default change detection.
- **Fix:**
  ```typescript
  @Component({
      changeDetection: ChangeDetectionStrategy.OnPush,
      ...
  })
  ```

---

### 7.3 Sin signals (patrón moderno)

- **Problema:** Solo `app.ts` usa `signal()`. Todos los demás usan propiedades mutables.
- **Fix:** Migrar a signals:
  ```typescript
  clients = signal<Client[]>([]);
  loading = signal(true);

  ngOnInit() {
      this.api.getClients().subscribe(data => {
          this.clients.set(data);
          this.loading.set(false);
      });
  }
  ```

---

### 7.4 getUser() parsea JSON en cada cycle

- **Archivo:** `control-master/src/app/core/auth.service.ts:39-42`
- **Problema:** `JSON.parse()` en cada llamada, incluyendo 2 veces en el template del layout.
- **Fix:** Cacheear:
  ```typescript
  private cachedUser: any = null;

  getUser() {
      if (!this.cachedUser) {
          this.cachedUser = JSON.parse(localStorage.getItem('usuario') || '{}');
      }
      return this.cachedUser;
  }
  ```

---

### 7.5 setTimeout sin cleanup

- **Archivo:** `operations.component.ts:117`
- **Fix:** Usar `DestroyRef`:
  ```typescript
  constructor(private destroyRef: DestroyRef) {}

  showMessage(msg: string) {
      this.message = msg;
      const timeout = setTimeout(() => this.message = '', 3000);
      this.destroyRef.onDestroy(() => clearTimeout(timeout));
  }
  ```

---

### 7.6 Wildcard route redirige doble

- **Archivo:** `control-master/src/app/app.routes.ts:21,24`
- **Problema:** `**` → `''` → `dashboard` (doble redirect).
- **Fix:**
  ```typescript
  { path: '**', redirectTo: 'dashboard' }
  ```

---

### 7.7 Sidebar sin responsive

- **Archivo:** `layout.component.ts:20,43`
- **Problema:** Sidebar siempre abierto, sin hamburger menu.
- **Fix:** Agregar toggle responsive con `mat-sidenav` mode `over` en mobile.

---

## Resumen de Prioridad

| Prioridad | Issues | Acción |
|-----------|--------|--------|
| 🔴 **P0 — Inmediato** | 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 6.1, 6.2 | Seguridad + funcionalidad rota |
| 🟠 **P1 — Esta semana** | 2.3-2.12, 5.1-5.8 | Lógica irregular + validaciones |
| 🟡 **P2 — Próximo sprint** | 3.1-3.9, 4.1-4.10 | Redundancias + inconsistencias |
| 🟢 **P3 — Backlog** | 6.3-6.8, 7.1-7.7 | Frontend improvements |

---

## Archivos Afectados (Resumen)

### Backend (24 archivos)
```
application-dev.yml, SecurityConfig.java, WebSocketConfig.java,
SuperSuService.java, MasterOperationsService.java, SyncService.java,
ReporteService.java, ReporteController.java, LicenciaService.java,
LicenciaController.java, MasterDashboardService.java, DailyCutService.java,
TransaccionService.java, TransaccionController.java, MasterClientService.java,
AuthService.java, MasterAuthService.java, MasterTeamService.java,
NegocioHelper.java, CajeroHelper.java, AdministradorHelper.java,
DuplicadoException.java, YaExisteException.java, YaRegistradoException.java,
InvitacionRepository.java, negociosController.java, SuperSuController.java
```

### Frontend (15 archivos)
```
auth.service.ts, auth.interceptor.ts, api.service.ts,
layout.component.ts, app.routes.ts, app.ts,
dashboard.component.ts, clients.component.ts, client-detail.component.ts,
tickets.component.ts, ticket-detail.component.ts,
operations.component.ts, team.component.ts, billing.component.ts,
login.component.ts
```
