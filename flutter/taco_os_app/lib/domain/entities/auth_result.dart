/// Resultado de la verificación de usuario en el backend
///
/// Se usa en el flujo de login para determinar si el usuario ya existe
/// y debe ir al dashboard, o si es nuevo y debe ir a registro.
///
/// Flujo: Google Sign-In → GET /verificar/{idGoogle} → AuthResult
class AuthResult {
  /// El usuario ya tiene cuenta en el backend
  final bool existe;

  /// JWT del backend (solo si existe = true)
  final String? token;

  /// Datos del usuario del backend (solo si existe = true)
  final Map<String, dynamic>? usuario;

  const AuthResult({
    required this.existe,
    this.token,
    this.usuario,
  });
}
