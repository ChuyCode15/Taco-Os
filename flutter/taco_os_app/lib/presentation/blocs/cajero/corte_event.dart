import 'package:equatable/equatable.dart';

/// Eventos del CorteBloc
///
/// Gestiona las acciones relacionadas con el proceso de Corte de Caja:
/// inicio del flujo, ingreso de efectivo contado, confirmación y rechazo del corte.
///
/// **Validates: Requirements 9.1, 9.3, 9.4, 9.8, 9.9**
sealed class CorteEvent extends Equatable {
  const CorteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado cuando el cajero inicia el proceso de Corte desde Modo_Cajero
///
/// Obtiene el resumen del turno actual y verifica si hay transacciones registradas.
/// Si el turno está vacío, solicitará confirmación explícita del cajero.
///
/// **Parámetros obligatorios:**
/// - [sessionId]: ID de la sesión de caja activa a cerrar
///
/// **Validates: Requirements 9.1, 9.8**
class CorteInitiated extends CorteEvent {
  final String sessionId;

  const CorteInitiated({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Evento disparado cuando el cajero ingresa el efectivo contado
///
/// El cajero ha contado el efectivo físico de la caja y lo registra en el campo numérico.
/// Este evento valida que el valor sea numérico y esté en el rango válido (0.00–999,999.99).
/// Si la validación es exitosa, transiciona a la vista de resumen del corte.
///
/// **Parámetros obligatorios:**
/// - [countedCash]: Monto de efectivo contado (0.00–999,999.99)
///
/// **Validaciones aplicadas (Requirement 9.2):**
/// - Valor numérico
/// - No negativo
/// - No superior a 999,999.99
///
/// **Validates: Requirements 9.1, 9.2**
class CashCountEntered extends CorteEvent {
  final double countedCash;

  const CashCountEntered({required this.countedCash});

  @override
  List<Object?> get props => [countedCash];
}

/// Evento disparado cuando el cajero confirma el corte
///
/// El cajero ha revisado el resumen con la diferencia calculada y confirma
/// explícitamente que desea finalizar el corte. Esto registra el cierre en Local_DB,
/// marca la sesión como cerrada, y genera el ticket digital.
///
/// **Parámetros obligatorios:**
/// - [countedCash]: Monto de efectivo contado confirmado por el cajero
///
/// **Validates: Requirements 9.3, 9.4**
class CorteConfirmed extends CorteEvent {
  final double countedCash;

  const CorteConfirmed({required this.countedCash});

  @override
  List<Object?> get props => [countedCash];
}

/// Evento disparado cuando el cajero rechaza el corte
///
/// El cajero ha decidido no completar el corte y regresar al Modo_Cajero.
/// Esto puede ocurrir si:
/// - El cajero detecta un error en el conteo de efectivo
/// - El turno está vacío y el cajero no desea continuar con el corte
///
/// No se escribe ningún dato en Local_DB. La sesión permanece abierta.
///
/// **Validates: Requirement 9.9**
class CorteRejected extends CorteEvent {
  const CorteRejected();
}
