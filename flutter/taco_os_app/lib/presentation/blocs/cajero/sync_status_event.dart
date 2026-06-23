import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Eventos del SyncStatusBloc
///
/// Gestiona las acciones relacionadas con el estado de sincronización:
/// verificación de estado y cambios en la conectividad de red.
///
/// **Validates: Requirement 10.10**
sealed class SyncStatusEvent extends Equatable {
  const SyncStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado para verificar el estado de sincronización de una sesión
///
/// Consulta las transacciones pendientes (is_synced = false) en Local_DB
/// y verifica la conectividad de red para determinar el estado apropiado:
/// - SyncSynced: todos sincronizados
/// - SyncPending: hay pendientes y hay conectividad
/// - SyncOffline: sin conectividad
///
/// **Validates: Requirement 10.10**
class CheckSyncStatus extends SyncStatusEvent {
  final String sessionId;

  const CheckSyncStatus({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Evento disparado cuando la conectividad de red cambia
///
/// Se dispara automáticamente mediante la suscripción a
/// [Connectivity.onConnectivityChanged]. Cuando se pierde la conexión,
/// emite [SyncOffline]; cuando se recupera, dispara [CheckSyncStatus]
/// para determinar el estado real de sincronización.
///
/// **Validates: Requirement 10.10**
class ConnectivityChanged extends SyncStatusEvent {
  final List<ConnectivityResult> results;

  const ConnectivityChanged({required this.results});

  @override
  List<Object?> get props => [results];
}
