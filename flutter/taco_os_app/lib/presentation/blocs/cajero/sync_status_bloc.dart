import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taco_os_app/core/network/network_info.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_state.dart';

/// BLoC para gestionar el estado de sincronización del turno activo
///
/// Escucha cambios de conectividad mediante [connectivity_plus] y consulta
/// el flag [is_synced] en Local_DB para determinar el estado de sincronización.
///
/// **Estados:**
/// - [SyncSynced]: Todos los registros del turno tienen is_synced = true
/// - [SyncPending]: Al menos un registro con is_synced = false y hay conectividad
/// - [SyncOffline]: No hay conectividad de red
///
/// **Eventos:**
/// - [CheckSyncStatus]: Verifica estado de sync para una sesión específica
/// - [ConnectivityChanged]: Detecta cambios en la conectividad de red
///
/// **Validates: Requirement 10.10**
class SyncStatusBloc extends Bloc<SyncStatusEvent, SyncStatusState> {
  final NetworkInfo _networkInfo;
  final ITransactionRepository _transactionRepository;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _currentSessionId;

  SyncStatusBloc({
    required NetworkInfo networkInfo,
    required ITransactionRepository transactionRepository,
    required Connectivity connectivity,
  }) : _networkInfo = networkInfo,
       _transactionRepository = transactionRepository,
       _connectivity = connectivity,
       super(const SyncOffline()) {
    on<CheckSyncStatus>(_onCheckSyncStatus);
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Suscribirse a cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      add(ConnectivityChanged(results: results));
    });
  }

  /// Maneja [CheckSyncStatus]
  ///
  /// 1. Verifica si hay conectividad de red
  /// 2. Si no hay conectividad: emite [SyncOffline]
  /// 3. Si hay conectividad:
  ///    a. Consulta ventas pendientes (is_synced = false) en Local_DB
  ///    b. Consulta gastos pendientes (is_synced = false) en Local_DB
  ///    c. Si hay pendientes: emite [SyncPending]
  ///    d. Si no hay pendientes: emite [SyncSynced]
  ///
  /// **Validates: Requirement 10.10**
  Future<void> _onCheckSyncStatus(
    CheckSyncStatus event,
    Emitter<SyncStatusState> emit,
  ) async {
    _currentSessionId = event.sessionId;

    // Verificar conectividad primero
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      emit(const SyncOffline());
      return;
    }

    // Consultar transacciones pendientes en Local_DB
    final salesResult = await _transactionRepository.getPendingSales(
      event.sessionId,
    );
    final expensesResult = await _transactionRepository.getPendingExpenses(
      event.sessionId,
    );

    // Si ambas consultas fallan, mantener estado offline por seguridad
    if (salesResult.isLeft() && expensesResult.isLeft()) {
      emit(const SyncOffline());
      return;
    }

    // Contar transacciones pendientes
    final pendingSalesCount = salesResult.fold(
      (_) => 0,
      (sales) => sales.length,
    );

    final pendingExpensesCount = expensesResult.fold(
      (_) => 0,
      (expenses) => expenses.length,
    );

    final totalPending = pendingSalesCount + pendingExpensesCount;

    // Determinar estado basado en transacciones pendientes
    if (totalPending > 0) {
      emit(SyncPending(pendingCount: totalPending));
    } else {
      emit(const SyncSynced());
    }
  }

  /// Maneja [ConnectivityChanged]
  ///
  /// Cuando la conectividad cambia, re-evalúa el estado de sincronización:
  /// 1. Si perdió conectividad: emite [SyncOffline] inmediatamente
  /// 2. Si recuperó conectividad: dispara [CheckSyncStatus] para determinar
  ///    si hay pendientes o si todo está sincronizado
  ///
  /// **Validates: Requirement 10.10**
  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncStatusState> emit,
  ) async {
    // Verificar si hay conectividad real
    final hasConnection =
        event.results.isNotEmpty &&
        !event.results.every((r) => r == ConnectivityResult.none);

    if (!hasConnection) {
      // Sin conexión → estado offline inmediato
      emit(const SyncOffline());
    } else if (_currentSessionId != null) {
      // Recuperó conexión → verificar estado de sync
      add(CheckSyncStatus(sessionId: _currentSessionId!));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
