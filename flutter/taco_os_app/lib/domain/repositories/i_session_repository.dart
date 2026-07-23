import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/entities/shift_summary.dart';

/// Parámetros para abrir una nueva sesión de caja
///
/// Validado por Requirement 3.2: Apertura de Caja (Inicio de Turno)
class OpenSessionParams {
  final String businessId;
  final String userId;
  final double initialCash;

  const OpenSessionParams({
    required this.businessId,
    required this.userId,
    required this.initialCash,
  });
}

/// Parámetros para cerrar una sesión de caja (Corte)
///
/// Validado por Requirement 9.4: Corte de Caja
class CloseSessionParams {
  final String sessionId;
  final double countedCash;

  const CloseSessionParams({
    required this.sessionId,
    required this.countedCash,
  });
}

/// Interfaz abstracta del repositorio de sesiones de caja
///
/// Define los contratos para la gestión de turnos de cajero desde apertura
/// hasta corte de caja. Implementaciones concretas deben manejar tanto
/// persistencia local (SQLite) como sincronización remota.
///
/// Validado por Requirement 13.1: Arquitectura Clean Code
/// Validado por Requirement 13.2: Principios SOLID (Dependency Inversion)
abstract class ISessionRepository {
  /// Abre una nueva sesión de caja para el cajero
  ///
  /// Registra el fondo de cambio (Fondo_de_Cambio) y el timestamp de apertura.
  /// La sesión se marca como `is_synced = false` hasta que el Sync_Service
  /// la sincronice con el backend.
  ///
  /// [params] contiene el businessId, userId y el monto inicial (0.00–999,999.99)
  ///
  /// Returns:
  /// - Right(CashSession) si la apertura fue exitosa
  /// - Left(ValidationFailure) si el monto está fuera del rango válido
  /// - Left(LocalDatabaseFailure) si falla la escritura en SQLite
  ///
  /// Validado por Requirement 3.2: Apertura de Caja (Inicio de Turno)
  /// Validado por Requirement 3.3: Conectividad al abrir caja no bloquea
  /// Validado por Requirement 3.6: Validación de Fondo_de_Cambio
  Future<Either<Failure, CashSession>> openSession(OpenSessionParams params);

  /// Cierra la sesión de caja activa (Corte)
  ///
  /// Calcula la diferencia entre el efectivo esperado y el contado, marca
  /// la sesión como cerrada y persiste el registro del corte en Local_DB.
  ///
  /// [params] contiene el sessionId y el monto de efectivo contado (0.00–999,999.99)
  ///
  /// Returns:
  /// - Right(CashSession) con closedAt, countedCash y difference calculados
  /// - Left(ValidationFailure) si el monto contado está fuera de rango
  /// - Left(LocalDatabaseFailure) si falla la escritura en SQLite
  ///
  /// Validado por Requirement 9.4: Corte de Caja
  /// Validado por Requirement 9.3: Cálculo de diferencia con confirmación
  /// Validado por Requirement 9.6: Marcar turno como cerrado tras Corte
  Future<Either<Failure, CashSession>> closeSession(CloseSessionParams params);

  /// Obtiene la sesión de caja activa para un negocio
  ///
  /// Retorna la sesión con status = SessionStatus.open para el businessId dado.
  /// Si no hay sesión activa, retorna Right(null).
  ///
  /// [businessId] el identificador del negocio (multi-tenant)
  ///
  /// Returns:
  /// - Right(CashSession) si existe una sesión activa
  /// - Right(null) si no hay sesión activa
  /// - Left(LocalDatabaseFailure) si falla la consulta
  ///
  /// Validado por Requirement 3.5: Bloqueo sin turno activo
  /// Validado por Requirement 15.2: Filtrado por business_id
  Future<Either<Failure, CashSession?>> getActiveSession(String businessId);

  /// Obtiene el resumen del turno activo (vista "¿Cómo voy?")
  ///
  /// Calcula totales de ventas, gastos y efectivo esperado desde Local_DB,
  /// incluyendo transacciones con is_synced = false.
  ///
  /// [sessionId] el identificador de la sesión de caja
  ///
  /// Returns:
  /// - Right(ShiftSummary) con todos los totales calculados
  /// - Left(LocalDatabaseFailure) si falla la consulta
  ///
  /// Validado por Requirement 8.1: Vista "¿Cómo voy?" — Resumen del Turno
  /// Validado por Requirement 8.2: Cálculo desde Local_DB sin conectividad
  /// Validado por Requirement 8.3: Incluir transacciones no sincronizadas
  Future<Either<Failure, ShiftSummary>> getShiftSummary(String sessionId);
}
