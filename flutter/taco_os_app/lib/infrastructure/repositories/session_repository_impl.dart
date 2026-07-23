import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/entities/shift_summary.dart' as domain;
import '../../domain/repositories/i_session_repository.dart';
import '../datasources/local/daos/session_dao.dart' as dao;

/// Implementación concreta del repositorio de sesiones de caja
///
/// Maneja la persistencia de turnos de cajero tanto en Local_DB (SQLite)
/// como la sincronización con el backend REST.
///
/// Validado por Requirement 13.2: Implementaciones concretas de interfaces
/// Validado por Requirement 15.1: Aislamiento multi-tenant por business_id
class SessionRepositoryImpl implements ISessionRepository {
  final dao.SessionDao sessionDao;

  SessionRepositoryImpl({required this.sessionDao});

  @override
  Future<Either<Failure, CashSession>> openSession(
    OpenSessionParams params,
  ) async {
    // TODO: Implement in future task
    throw UnimplementedError(
      'openSession will be implemented in a future task',
    );
  }

  @override
  Future<Either<Failure, CashSession>> closeSession(
    CloseSessionParams params,
  ) async {
    // TODO: Implement in future task
    throw UnimplementedError(
      'closeSession will be implemented in a future task',
    );
  }

  @override
  Future<Either<Failure, CashSession?>> getActiveSession(
    String businessId,
  ) async {
    try {
      final sessionData = await sessionDao.getActiveSession(businessId);

      if (sessionData == null) {
        return right(null);
      }

      // Convert drift data model to domain entity
      final cashSession = CashSession(
        id: sessionData.id,
        businessId: sessionData.businessId,
        userId: sessionData.cashierId, // cashierId is the userId in domain
        initialCash: sessionData.openingBalance,
        status: sessionData.status == 'open'
            ? SessionStatus.open
            : SessionStatus.closed,
        openedAt: sessionData.openedAt,
        closedAt: sessionData.closedAt,
        countedCash: null, // Not set until corte
        difference: null, // Not set until corte
      );

      return right(cashSession);
    } catch (e) {
      return left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.ShiftSummary>> getShiftSummary(
    String sessionId,
  ) async {
    // TODO: Implement in future task
    throw UnimplementedError(
      'getShiftSummary will be implemented in a future task',
    );
  }
}
