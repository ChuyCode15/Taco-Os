import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';

/// Parámetros para verificar la sesión activa
///
/// Incluye el tiempo que la app ha estado en segundo plano para
/// validar la regla de 12 horas máximo.
class CheckSessionParams {
  /// Tiempo en milisegundos que la app ha estado en segundo plano
  final int backgroundTimeMs;

  const CheckSessionParams({required this.backgroundTimeMs});

  /// Calcula si el tiempo en segundo plano excede 12 horas
  bool get exceedsBackgroundLimit {
    const twelveHoursMs = 12 * 60 * 60 * 1000; // 12 horas en milisegundos
    return backgroundTimeMs >= twelveHoursMs;
  }
}

/// Use case para verificar la sesión activa del usuario
///
/// Valida que el JWT sea válido y que el turno no haya superado
/// las 12 horas en segundo plano. Si alguna condición falla,
/// invalida la sesión y requiere re-autenticación.
///
/// **Validates: Requirements 1.6, 1.7, 1.8**
///
/// **Reglas de validación:**
/// - JWT debe ser válido (no expirado)
/// - Tiempo en segundo plano debe ser < 12 horas
/// - Si ambas condiciones se cumplen, mantiene la sesión
/// - Si alguna falla, invalida la sesión y retorna null
///
/// **Returns:**
/// - `Right(User)`: Sesión válida, usuario autenticado
/// - `Right(null)`: Sesión inválida (JWT expiró o > 12h en background)
/// - `Left(AuthFailure)`: Error al validar el token
///
/// **Example:**
/// ```dart
/// final result = await checkSessionUseCase(
///   CheckSessionParams(backgroundTimeMs: appBackgroundTime),
/// );
/// result.fold(
///   (failure) => navigateToLogin(),
///   (user) => user != null ? showHome(user) : navigateToLogin(),
/// );
/// ```
class CheckSessionUseCase extends UseCase<User?, CheckSessionParams> {
  final IAuthRepository repository;

  CheckSessionUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(CheckSessionParams params) async {
    // Validar tiempo en segundo plano antes de consultar el repositorio
    if (params.exceedsBackgroundLimit) {
      // Requisito 1.7: Invalidar sesión si > 12h en segundo plano
      // El repositorio se encargará de limpiar el JWT
      await repository.signOut();
      return right(null);
    }

    // Obtener usuario actual y validar JWT
    final result = await repository.getCurrentUser();

    return result.fold((failure) => left(failure), (user) {
      // Si el JWT expiró, el repositorio retorna null
      // Requisito 1.8: JWT expirado invalida la sesión
      if (user == null) {
        return right(null);
      }

      // Requisito 1.6: Mantener sesión mientras JWT es válido
      // y tiempo en background < 12h
      return right(user);
    });
  }
}
