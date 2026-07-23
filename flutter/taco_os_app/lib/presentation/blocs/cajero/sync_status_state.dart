import 'package:equatable/equatable.dart';

/// Estados del SyncStatusBloc
///
/// Representa el estado de sincronización de las transacciones del turno activo.
/// Este estado se muestra en el header del Modo_Cajero como indicador visual.
///
/// **Validates: Requirement 10.10**
sealed class SyncStatusState extends Equatable {
  const SyncStatusState();

  @override
  List<Object?> get props => [];
}

/// Estado cuando todos los registros del turno tienen is_synced = true
///
/// Indica que todas las transacciones (ventas, gastos) han sido sincronizadas
/// exitosamente con el backend. Se muestra con un indicador visual verde o ✅.
///
/// **Validates: Requirement 10.10**
class SyncSynced extends SyncStatusState {
  const SyncSynced();
}

/// Estado cuando al menos un registro tiene is_synced = false y hay conectividad
///
/// Indica que hay transacciones pendientes de sincronización y el dispositivo
/// tiene conectividad de red. El SyncService intentará sincronizarlas en el
/// próximo ciclo de 5 minutos. Se muestra con un indicador visual naranja o 🔄.
///
/// **Validates: Requirement 10.10**
class SyncPending extends SyncStatusState {
  final int pendingCount;

  const SyncPending({required this.pendingCount});

  @override
  List<Object?> get props => [pendingCount];
}

/// Estado cuando no hay conectividad de red
///
/// Indica que el dispositivo no tiene conexión a internet. Las transacciones
/// se registran normalmente en Local_DB y se sincronizarán cuando se recupere
/// la conectividad. Se muestra con un indicador visual rojo o 📴.
///
/// **Validates: Requirement 10.10**
class SyncOffline extends SyncStatusState {
  const SyncOffline();
}
