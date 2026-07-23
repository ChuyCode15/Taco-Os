import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';

/// Parámetros para cerrar una sesión de caja (Corte)
class CloseSessionUseCaseParams {
  final String sessionId;
  final double countedCash;

  const CloseSessionUseCaseParams({
    required this.sessionId,
    required this.countedCash,
  });
}

/// Use case para cerrar una sesión de caja (Corte)
///
/// Valida el efectivo contado y delega al ISessionRepository para calcular
/// la diferencia y registrar el cierre en Local_DB.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Valida el monto del efectivo contado (0.00–999,999.99)
/// 2. Invoca `ISessionRepository.closeSession()` con los parámetros validados
/// 3. El repositorio calcula la diferencia (countedCash - expectedCash)
/// 4. El repositorio registra el corte en Local_DB con is_synced = false
/// 5. El repositorio marca la sesión como cerrada
/// 6. Retorna la sesión cerrada al éxito
///
/// **Returns:**
/// - `Right(CashSession)`: Sesión cerrada exitosamente con diferencia calculada
/// - `Left(ValidationFailure)`: Efectivo contado fuera de rango válido
/// - `Left(LocalDatabaseFailure)`: Error al escribir en SQLite
///
/// **Example:**
/// ```dart
/// final result = await closeSessionUseCase(
///   CloseSessionUseCaseParams(
///     sessionId: 'session-456',
///     countedCash: 1523.50,
///   ),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (session) => print('Corte completado con diferencia: ${session.difference}'),
/// );
/// ```
class CloseSessionUseCase
    extends UseCase<CashSession, CloseSessionUseCaseParams> {
  final ISessionRepository repository;

  CloseSessionUseCase(this.repository);

  @override
  Future<Either<Failure, CashSession>> call(
    CloseSessionUseCaseParams params,
  ) async {
    // Validar el efectivo contado usando Validators
    final validation = CountedCashValidator.validateValue(params.countedCash);

    if (!validation.isValid) {
      return Left(
        ValidationFailure(
          message: validation.errorMessage ?? 'Efectivo contado inválido',
        ),
      );
    }

    // Delegar al repositorio para cerrar la sesión y calcular diferencia
    return await repository.closeSession(
      CloseSessionParams(
        sessionId: params.sessionId,
        countedCash: params.countedCash,
      ),
    );
  }
}
