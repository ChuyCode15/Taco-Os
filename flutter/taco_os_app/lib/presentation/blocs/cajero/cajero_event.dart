import 'package:equatable/equatable.dart';

/// Eventos del CajeroBloc
///
/// Gestiona las acciones relacionadas con el ciclo de vida del turno
/// del cajero: apertura, cierre, y carga de sesión activa.
///
/// **Validates: Requirements 3.1, 3.2, 3.5**
sealed class CajeroEvent extends Equatable {
  const CajeroEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado cuando el cajero solicita abrir una nueva sesión
///
/// Requiere el businessId, userId y el monto del Fondo_de_Cambio.
/// Al procesarse, dispara [OpenSessionUseCase] con validación incluida.
///
/// **Validates: Requirement 3.2**
class OpenSessionRequested extends CajeroEvent {
  final String businessId;
  final String userId;
  final double initialCash;

  const OpenSessionRequested({
    required this.businessId,
    required this.userId,
    required this.initialCash,
  });

  @override
  List<Object?> get props => [businessId, userId, initialCash];
}

/// Evento disparado cuando el cajero solicita cerrar la sesión activa (Corte)
///
/// Requiere el sessionId y el monto de efectivo contado manualmente.
/// Al procesarse, dispara [CloseSessionUseCase].
///
/// **Validates: Requirement 9.4**
class CloseSessionRequested extends CajeroEvent {
  final String sessionId;
  final double countedCash;

  const CloseSessionRequested({
    required this.sessionId,
    required this.countedCash,
  });

  @override
  List<Object?> get props => [sessionId, countedCash];
}

/// Evento disparado para cargar la sesión activa desde Local_DB
///
/// Se utiliza al iniciar la aplicación para verificar si hay un turno activo.
/// Si existe, el BLoC emite [TurnoActivo]; de lo contrario, [TurnoCerrado].
///
/// **Validates: Requirement 3.5**
class SessionLoaded extends CajeroEvent {
  final String businessId;

  const SessionLoaded({required this.businessId});

  @override
  List<Object?> get props => [businessId];
}
