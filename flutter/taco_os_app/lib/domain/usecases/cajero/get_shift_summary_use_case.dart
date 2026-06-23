import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/shift_summary.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';

/// Parámetros para obtener el resumen del turno
class GetShiftSummaryParams {
  final String sessionId;

  const GetShiftSummaryParams({required this.sessionId});
}

/// Use case para obtener el resumen del turno activo (vista "¿Cómo voy?")
///
/// Delega al ISessionRepository para calcular los totales desde Local_DB,
/// incluyendo transacciones no sincronizadas.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Invoca `ISessionRepository.getShiftSummary()` con el sessionId
/// 2. El repositorio calcula totales de ventas, gastos y efectivo esperado
/// 3. El cálculo incluye transacciones con is_synced = false
/// 4. Retorna el resumen calculado al éxito
///
/// **Returns:**
/// - `Right(ShiftSummary)`: Resumen calculado exitosamente
/// - `Left(LocalDatabaseFailure)`: Error al consultar SQLite
///
/// **Example:**
/// ```dart
/// final result = await getShiftSummaryUseCase(
///   GetShiftSummaryParams(sessionId: 'session-456'),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (summary) => print('Total ventas: \$${summary.totalSales}'),
/// );
/// ```
class GetShiftSummaryUseCase
    extends UseCase<ShiftSummary, GetShiftSummaryParams> {
  final ISessionRepository repository;

  GetShiftSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ShiftSummary>> call(
    GetShiftSummaryParams params,
  ) async {
    // Validar que el sessionId no esté vacío
    if (params.sessionId.isEmpty) {
      return Left(
        ValidationFailure(message: 'El identificador de sesión es requerido'),
      );
    }

    // Delegar al repositorio para obtener el resumen
    return await repository.getShiftSummary(params.sessionId);
  }
}
