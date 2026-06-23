/// Base class for all infrastructure-layer exceptions.
///
/// These are thrown by data sources and caught by repository implementations,
/// which convert them into the appropriate [Failure] subclass.
class AppException implements Exception {
  final String message;
  const AppException({required this.message});

  @override
  String toString() => 'AppException: $message';
}

/// Thrown by remote data sources when there is no network connectivity.
class NetworkException extends AppException {
  const NetworkException({super.message = 'Sin conexión a internet'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when there is internet connectivity but the backend server is unreachable.
class BackendUnavailableException extends AppException {
  const BackendUnavailableException({
    super.message =
        'No se puede conectar con el servidor. Verifica que el backend esté activo.',
  });

  @override
  String toString() => 'BackendUnavailableException: $message';
}

/// Thrown when a request times out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'La conexión está tardando demasiado. Intenta de nuevo.',
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Thrown by remote data sources when the server responds with 4xx or 5xx.
class ServerException extends AppException {
  final int statusCode;
  const ServerException({
    required this.statusCode,
    super.message = 'Error del servidor',
  });

  @override
  String toString() => 'ServerException[$statusCode]: $message';
}

/// Thrown by local data sources when a drift / SQLite operation fails.
class LocalDatabaseException extends AppException {
  const LocalDatabaseException({
    super.message = 'Error en la base de datos local',
  });

  @override
  String toString() => 'LocalDatabaseException: $message';
}

/// Thrown when input data fails domain validation before a write.
class ValidationException extends AppException {
  const ValidationException({required super.message});

  @override
  String toString() => 'ValidationException: $message';
}

/// Thrown when authentication fails or the JWT token has expired.
class AuthException extends AppException {
  const AuthException({
    super.message = 'Sesión expirada o credenciales inválidas',
  });

  @override
  String toString() => 'AuthException: $message';
}

/// Thrown when the camera is unavailable or the user cancels a required capture.
class CameraException extends AppException {
  const CameraException({
    super.message = 'Cámara no disponible o captura cancelada',
  });

  @override
  String toString() => 'CameraException: $message';
}

/// Thrown when the current subscription plan limit has been reached.
class LicenseLimitException extends AppException {
  const LicenseLimitException({super.message = 'Límite del plan alcanzado'});

  @override
  String toString() => 'LicenseLimitException: $message';
}
