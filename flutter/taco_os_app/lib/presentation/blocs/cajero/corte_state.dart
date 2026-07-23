import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/entities/shift_summary.dart';

/// Estados del CorteBloc
///
/// Representa el flujo completo del proceso de Corte de Caja:
/// estado inicial, ingreso de efectivo contado, resumen del corte con diferencia,
/// éxito con ticket digital, y errores de validación o base de datos.
///
/// **Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9**
sealed class CorteState extends Equatable {
  const CorteState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del flujo de corte
///
/// El cajero está en el Modo_Cajero y aún no ha iniciado el proceso de corte.
///
/// **Validates: Requirement 9.1**
class CorteInitial extends CorteState {
  const CorteInitial();
}

/// Estado de entrada de efectivo contado
///
/// El cajero está en la pantalla de conteo de efectivo físico,
/// ingresando el monto contado en el campo numérico.
///
/// **Parámetros:**
/// - [sessionId]: ID de la sesión de caja activa
/// - [shiftSummary]: Resumen del turno actual (usado para calcular diferencia)
/// - [hasNoTransactions]: Indica si el turno está vacío (para mostrar alerta)
///
/// **Validates: Requirements 9.1, 9.2, 9.8**
class CorteCountInput extends CorteState {
  final String sessionId;
  final ShiftSummary shiftSummary;
  final bool hasNoTransactions;

  const CorteCountInput({
    required this.sessionId,
    required this.shiftSummary,
    required this.hasNoTransactions,
  });

  @override
  List<Object?> get props => [sessionId, shiftSummary, hasNoTransactions];
}

/// Estado de resumen del corte con diferencia calculada
///
/// Muestra el efectivo contado, el efectivo esperado y la diferencia.
/// El cajero debe confirmar explícitamente antes de finalizar el corte.
///
/// **Parámetros:**
/// - [sessionId]: ID de la sesión de caja activa
/// - [shiftSummary]: Resumen del turno actual
/// - [countedCash]: Efectivo contado por el cajero
/// - [expectedCash]: Efectivo esperado calculado
/// - [difference]: Diferencia entre contado y esperado (positivo = sobrante, negativo = faltante)
/// - [hasNoTransactions]: Indica si el turno está vacío
///
/// **Validates: Requirements 9.3, 9.8, 9.9**
class CorteSummaryView extends CorteState {
  final String sessionId;
  final ShiftSummary shiftSummary;
  final double countedCash;
  final double expectedCash;
  final double difference;
  final bool hasNoTransactions;

  const CorteSummaryView({
    required this.sessionId,
    required this.shiftSummary,
    required this.countedCash,
    required this.expectedCash,
    required this.difference,
    required this.hasNoTransactions,
  });

  @override
  List<Object?> get props => [
    sessionId,
    shiftSummary,
    countedCash,
    expectedCash,
    difference,
    hasNoTransactions,
  ];
}

/// Estado de corte completado exitosamente
///
/// El corte fue registrado en Local_DB, la sesión fue marcada como cerrada,
/// y se generó el ticket digital con todos los detalles del turno.
///
/// **Parámetros:**
/// - [session]: Sesión de caja cerrada con diferencia calculada
/// - [shiftSummary]: Resumen del turno cerrado
///
/// **Validates: Requirements 9.4, 9.5, 9.6, 9.7**
class CorteSuccess extends CorteState {
  final CashSession session;
  final ShiftSummary shiftSummary;

  const CorteSuccess({required this.session, required this.shiftSummary});

  @override
  List<Object?> get props => [session, shiftSummary];
}

/// Estado de error de validación en el efectivo contado
///
/// Indica que el efectivo contado no cumple con las validaciones:
/// - Valor no numérico
/// - Valor negativo
/// - Valor superior a 999,999.99
///
/// La pantalla de conteo permanece visible con el mensaje de error.
/// No se escribe nada en Local_DB.
///
/// **Validates: Requirement 9.2**
class CorteValidationError extends CorteState {
  final String message;

  const CorteValidationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de error al cerrar la sesión en Local_DB
///
/// Indica que hubo un error al escribir el corte en la base de datos local.
/// El cajero puede reintentar la operación.
///
/// **Validates: Requirement 9.4 (error handling)**
class CorteError extends CorteState {
  final String message;

  const CorteError({required this.message});

  @override
  List<Object?> get props => [message];
}
