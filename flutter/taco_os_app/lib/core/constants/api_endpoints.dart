/// All REST API endpoint paths used by the remote data sources.
///
/// Every path is relative to [ApiEndpoints.baseUrl].  Parameterised segments
/// are represented as named constants that require string interpolation at the
/// call-site, e.g.:
///
/// ```dart
/// final url =
///     '${ApiEndpoints.baseUrl}${ApiEndpoints.productsByCategory('comida')}';
/// ```
///
/// Requirements: 13.1, 13.5
class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  // ── Base ──────────────────────────────────────────────────────────────────

  /// Root URL of the Taco'Os Spring Boot backend.
  /// Replace with the real URL via environment configuration before release.
  static const String baseUrl = 'https://api.tacoOs.example.com';

  /// API version prefix shared by all versioned endpoints.
  static const String _v1 = '/api/v1';

  // ── Authentication ────────────────────────────────────────────────────────

  /// POST — Exchange a Google ID token for a Taco'Os JWT.
  /// Body: `{ "googleIdToken": "<token>" }`
  static const String authGoogleSignIn = '$_v1/auth/google';

  /// POST — Invalidate the current JWT on the backend.
  /// Requires `Authorization: Bearer <token>` header.
  static const String authSignOut = '$_v1/auth/sign-out';

  /// GET — Validate the current JWT and return the authenticated user profile.
  /// Requires `Authorization: Bearer <token>` header.
  static const String authMe = '$_v1/auth/me';

  // ── Transactions (batch sync) ─────────────────────────────────────────────

  /// POST — Submit a batch of pending transactions (sales, expenses, cortes).
  /// Body: `{ "transactions": [ ... ] }` (max 100 items per batch).
  /// Requires `Authorization: Bearer <token>` header.
  static const String transactionsBatch = '$_v1/transactions/batch';

  // ── Products / catalog ────────────────────────────────────────────────────

  /// GET — Retrieve all active products for a given category.
  ///
  /// [businessId] the tenant identifier.
  /// [category]   one of `comida`, `bebidas`, `postres`.
  ///
  /// Example: `/api/v1/businesses/abc123/products?category=comida`
  static String productsByCategory(String businessId, String category) =>
      '$_v1/businesses/$businessId/products?category=$category';

  /// POST — Trigger a full catalog sync for the given business.
  /// Requires `Authorization: Bearer <token>` header.
  static String catalogSync(String businessId) =>
      '$_v1/businesses/$businessId/catalog/sync';

  // ── Business ──────────────────────────────────────────────────────────────

  /// GET — Retrieve the profile for a specific business.
  /// Requires `Authorization: Bearer <token>` header.
  static String business(String businessId) => '$_v1/businesses/$businessId';

  /// POST — Create a new business for the authenticated Patron.
  /// Requires `Authorization: Bearer <token>` header.
  static const String businessCreate = '$_v1/businesses';

  /// GET — Retrieve the QR code payload for a business.
  /// Requires `Authorization: Bearer <token>` header.
  static String businessQrCode(String businessId) =>
      '$_v1/businesses/$businessId/qr-code';

  /// POST — Regenerate the QR code for a business.
  /// Requires `Authorization: Bearer <token>` header.
  static String businessQrCodeRegenerate(String businessId) =>
      '$_v1/businesses/$businessId/qr-code/regenerate';

  // ── Cashiers (team management) ────────────────────────────────────────────

  /// GET — List all cashiers linked to a business.
  /// Requires `Authorization: Bearer <token>` header.
  static String cashiers(String businessId) =>
      '$_v1/businesses/$businessId/cashiers';

  /// POST — Send an invitation / link a cashier to a business via QR payload.
  /// Requires `Authorization: Bearer <token>` header.
  static String cashierLink(String businessId) =>
      '$_v1/businesses/$businessId/cashiers/link';

  // ── Reports ───────────────────────────────────────────────────────────────

  /// GET — Retrieve sales and expense report for a date range.
  /// Query params: `from=<ISO date>&to=<ISO date>`
  /// Requires `Authorization: Bearer <token>` header.
  static String reports(String businessId) =>
      '$_v1/businesses/$businessId/reports';
}
