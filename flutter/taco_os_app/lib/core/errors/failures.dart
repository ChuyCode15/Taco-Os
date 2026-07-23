import 'package:taco_os_app/domain/entities/business.dart'
    show SubscriptionPlan;

/// Base sealed class for all domain failures.
///
/// Use [message] for user-facing or logging messages.
/// Pattern-match on the subclass to determine the specific failure type.
sealed class Failure {
  final String message;
  const Failure({required this.message});
}

/// Thrown when there is no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet'});
}

/// Thrown when there is internet but the backend server is unreachable.
class BackendUnavailableFailure extends Failure {
  const BackendUnavailableFailure({
    super.message =
        'No se puede conectar con el servidor. Verifica que el backend esté activo.',
  });
}

/// Thrown when a request times out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'La conexión está tardando demasiado. Intenta de nuevo.',
  });
}

/// Thrown when the backend returns a 4xx or 5xx response.
class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure({
    required this.statusCode,
    super.message = 'Error del servidor',
  });
}

/// Thrown when a local SQLite / drift operation fails.
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    super.message = 'Error en la base de datos local',
  });
}

/// Thrown when user input fails domain validation
/// (e.g. monto fuera de rango, cantidad inválida).
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Thrown when authentication fails or the JWT has expired.
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Sesión expirada o credenciales inválidas',
  });
}

/// Thrown when the user cancels the Google Sign-In flow.
/// This is NOT an error - the user intentionally cancelled.
///
/// **Validates: Requirement 1.4**
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure({
    super.message = 'Inicio de sesión cancelado por el usuario',
  });
}

/// Thrown when the camera is unavailable or the user cancels
/// a required photo capture (cancelación / pago con tarjeta).
class CameraFailure extends Failure {
  const CameraFailure({
    super.message = 'Cámara no disponible o captura cancelada',
  });
}

/// Thrown when the current subscription plan limit has been reached.
class LicenseLimitFailure extends Failure {
  final SubscriptionPlan currentPlan;
  const LicenseLimitFailure({
    required this.currentPlan,
    super.message = 'Límite del plan alcanzado',
  });
}
