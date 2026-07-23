/// All REST API endpoint paths used by the remote data sources.
///
/// Every path is relative to [ApiEndpoints.baseUrl]. Parameterised segments
/// are represented as named constants that require string interpolation at the
/// call-site, e.g.:
///
/// ```dart
/// final url =
///     '${ApiEndpoints.baseUrl}${ApiEndpoints.productsByCategory('comida')}';
/// ```
///
/// Justification: Backend uses RESTful singular paths (e.g. /business, not
/// /businesses) following industry standards (GitHub API, Stripe API).
/// All paths are aligned with the Spring Boot backend at localhost:8080.
class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  // ── Base ──────────────────────────────────────────────────────────────────

  /// Root URL of the Taco'Os Spring Boot backend.
  /// Use --dart-define=API_BASE_URL=... for production builds.
  /// Android emulator uses 10.0.2.2 to reach host localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// API version prefix shared by all versioned endpoints.
  static const String _v1 = '/api/v1';

  // ── Authentication ────────────────────────────────────────────────────────

  /// GET — Check if a Google user already exists in the system.
  /// Path param: [idGoogle] — Google account ID (googleUser.id).
  /// Returns: DatosVerificacionAuth { existe, token, vencimiento, usuario }.
  ///
  /// Justification: Backend uses a 2-step auth flow (verify + register)
  /// instead of a single /auth/google endpoint. This separates authentication
  /// (Google) from authorization (backend JWT) and avoids token injection risks.
  static String authVerificar(String idGoogle) => '$_v1/auth/verificar/$idGoogle';

  /// POST — Register a new user in the system.
  /// Body: { idGoogle, nickname, correo, numero, rol }.
  /// Returns: DatosRespuestaAuth { token, vencimiento, usuario }.
  ///
  /// Justification: Backend requires explicit registration with role selection.
  /// Google provides idGoogle, nickname, correo; numero and rol are user-provided.
  static const String authRegistrar = '$_v1/auth/registrar';

  /// POST — Refresh an expiring JWT token.
  /// Body: { token }.
  /// Returns: { token, expires_in }.
  ///
  /// Justification: JWT expires in 1 hour. Without refresh, users would be
  /// forced to re-login every hour. This endpoint avoids that.
  static const String authRefresh = '$_v1/auth/refresh';

  // ── Transactions (batch sync) ─────────────────────────────────────────────

  /// POST — Submit a batch of pending transactions for synchronization.
  /// Body: { cajeroId, sesionId, transacciones: [...] }.
  /// Returns: { sincronizadas, fallidas, mensaje }.
  ///
  /// Justification: Backend has a dedicated /sync endpoint for batch operations.
  /// /transactions is for single transaction creation only.
  static const String sync = '$_v1/sync';

  /// POST — Register a single transaction (sale or expense).
  /// Body: DatosRegistroTransaccion { business_id, session_id, type, ... }.
  /// Returns: DatosRespuestaTransaccion { id, status, timestamp }.
  ///
  /// Justification: Single transaction endpoint for real-time registration
  /// (non-offline mode).
  static const String transactions = '$_v1/transactions';

  /// POST — Cancel a transaction by ID.
  /// Path param: [transactionId].
  /// Body: DatosCancelacion { reason, photo, cashier_id }.
  ///
  /// Justification: Cancellation requires evidence photo and reason.
  /// Backend enforces a 5-minute cancellation window.
  static String transactionCancel(String transactionId) =>
      '$_v1/transactions/$transactionId/cancel';

  // ── Products / catalog ────────────────────────────────────────────────────

  /// GET — Retrieve all active products for a given category.
  ///
  /// [businessId] the tenant identifier.
  /// [category]   one of COMIDA, BEBIDAS, POSTRES (backend enum).
  ///
  /// Justification: Backend uses singular /business (not /businesses) and
  /// returns a paginated Page<> response. Flutter should handle pagination.
  static String productsByCategory(String businessId, String category) =>
      '$_v1/business/$businessId/products?category=$category';

  /// GET — Retrieve all active products for a business (no category filter).
  static String productsAll(String businessId) =>
      '$_v1/business/$businessId/products';

  // ── Business ──────────────────────────────────────────────────────────────

  /// GET — Retrieve the profile for a specific business.
  /// Returns: DatosDetalleNegocio { id, nombre, direccion, telefono, ... }.
  ///
  /// Justification: Backend uses singular /business path (REST standard).
  static String business(String businessId) => '$_v1/business/$businessId';

  /// POST — Create a new business for the authenticated owner.
  /// Body: DatosRegistroNegocio { nombre, direccion, telefono, ... }.
  /// Query param: duenoId (owner user ID).
  ///
  /// Justification: Backend requires duenoId as query param to associate
  /// the business with the owner at creation time.
  static const String businessCreate = '$_v1/business';

  /// PUT — Update an existing business.
  static String businessUpdate(String businessId) => '$_v1/business/$businessId';

  // ── Cashiers (team management) ────────────────────────────────────────────

  /// GET — List all cashiers linked to a business.
  /// Returns: DatosListaCajeros.
  ///
  /// Justification: Backend uses Spanish path /cajeros for consistency
  /// with internal naming conventions.
  static String cashiers(String businessId) =>
      '$_v1/business/$businessId/cajeros';

  /// POST — Generate an invitation code for linking cashiers.
  /// Body: { negocioId, duenoId }.
  ///
  /// Justification: Backend uses /invitation endpoint for generating
  /// invite codes. The cashier then uses /link to connect.
  static const String businessInvitation = '$_v1/business/invitation';

  /// POST — Link a cashier to a business using an invitation code.
  /// Body: { codigo, usuarioId }.
  ///
  /// Justification: Separate endpoint from cashier listing. The link
  /// operation is a business-level action, not a sub-resource of cashiers.
  static const String businessLink = '$_v1/business/link';

  // ── Cashier Sessions ──────────────────────────────────────────────────────

  /// POST — Open a new cashier session.
  /// Body: DatosAperturaSesion { businessId, cashierId, deviceId, opening_balance }.
  ///
  /// Justification: Sessions have dedicated endpoints (/cashier/open-session,
  /// /cashier/close-session) separate from business operations.
  static const String sessionOpen = '$_v1/cashier/open-session';

  /// POST — Close a cashier session (triggers daily cut).
  /// Body: DatosCierreSesion { session_id, cashier_id, device_id, actual_cash, notes }.
  static const String sessionClose = '$_v1/cashier/close-session';

  // ── Notifications ─────────────────────────────────────────────────────────

  /// GET — List notifications for a business.
  static String notifications(String businessId) =>
      '$_v1/business/$businessId/notifications';

  /// PUT — Mark a notification as read.
  static String notificationMarkRead(String businessId, String notificacionId) =>
      '$_v1/business/$businessId/notifications/$notificacionId/read';

  /// PUT — Mark all notifications as read.
  static String notificationsMarkAllRead(String businessId) =>
      '$_v1/business/$businessId/notifications/read-all';

  // ── Reports ───────────────────────────────────────────────────────────────

  /// GET — Retrieve open sessions report.
  static String reportsOpenSessions(String businessId) =>
      '$_v1/business/$businessId/reports/open-sessions';

  /// GET — Retrieve daily cuts report.
  static String reportsCuts(String businessId) =>
      '$_v1/business/$businessId/reports/cuts';

  /// GET — Retrieve business statistics.
  static String reportsStats(String businessId) =>
      '$_v1/business/$businessId/reports/stats';

  // ── License ───────────────────────────────────────────────────────────────

  /// GET — Retrieve license details for a business.
  static String license(String businessId) =>
      '$_v1/business/$businessId/license';

  /// POST — Upgrade plan.
  static String licenseUpgrade(String businessId) =>
      '$_v1/business/$businessId/license/upgrade';

  /// POST — Activate trial.
  static String licenseTrial(String businessId) =>
      '$_v1/business/$businessId/license/trial';

  /// GET — List all available plans.
  static const String plans = '$_v1/plans';

  // ── Files ─────────────────────────────────────────────────────────────────

  /// POST — Upload a file (multipart/form-data).
  /// Fields: file (File), type (String: "cancellation", "profile", etc.).
  ///
  /// Justification: Backend has a dedicated /files/upload endpoint for
  /// handling file uploads. Photos for cancellations should be uploaded
  /// first, then the URL is passed in the cancel request.
  static const String filesUpload = '$_v1/files/upload';
}
