import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';

/// Parámetros para abrir una sesión de caja
class OpenSessionUseCaseParams {
  final String businessId;
  final String userId;
  final double initialCash;

  const OpenSessionUseCaseParams({
    required this.businessId,
    required this.userId,
    required this.initialCash,
  });
}

/// Use case para abrir una sesión de caja (inicio de turno)
///
/// Valida el Fondo_de_Cambio con Validators y delega al ISessionRepository
/// para registrar la apertura en Local_DB.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Valida el monto del Fondo_de_Cambio (0.00–999,999.99)
/// 2. Invoca `ISessionRepository.openSession()` con los parámetros validados
/// 3. El repositorio registra la apertura en Local_DB con is_synced = false
/// 4. Retorna la sesión creada al éxito
///
/// **Returns:**
/// - `Right(CashSession)`: Sesión abierta exitosamente
/// - `Left(ValidationFailure)`: Fondo_de_Cambio fuera de rango válido
/// - `Left(LocalDatabaseFailure)`: Error al escribir en SQLite
///
/// **Example:**
/// ```dart
/// final result = await openSessionUseCase(
///   OpenSessionUseCaseParams(
///     businessId: 'biz-123',
///     userId: 'user-456',
///     initialCash: 500.00,
///   ),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (session) => print('Turno iniciado: ${session.id}'),
/// );
/// ```
class OpenSessionUseCase
    extends UseCase<CashSession, OpenSessionUseCaseParams> {
  final ISessionRepository repository;

  OpenSessionUseCase(this.repository);

  @override
  Future<Either<Failure, CashSession>> call(
    OpenSessionUseCaseParams params,
  ) async {
    // Validación del Fondo_de_Cambio usando Validators
    final validation = FondoDeCambioValidator.validateValue(params.initialCash);

    if (!validation.isValid) {
      return Left(
        ValidationFailure(message: validation.errorMessage ?? 'Monto inválido'),
      );
    }

    // Delegar al repositorio para registrar la apertura
    return await repository.openSession(
      OpenSessionParams(
        businessId: params.businessId,
        userId: params.userId,
        initialCash: params.initialCash,
      ),
    );
  }
}
