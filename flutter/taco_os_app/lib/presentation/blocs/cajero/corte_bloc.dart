import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/domain/usecases/cajero/close_session_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/get_shift_summary_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_state.dart';

/// BLoC para gestionar el flujo de Corte de Caja en el Modo_Cajero
///
/// Maneja el proceso completo de cierre de turno:
/// 1. Inicia el corte obteniendo el resumen del turno
/// 2. Valida el efectivo contado ingresado por el cajero
/// 3. Calcula la diferencia entre efectivo esperado y contado
/// 4. Solicita confirmación explícita del cajero
/// 5. Registra el cierre en Local_DB y genera ticket digital
/// 6. Si el turno está vacío, solicita confirmación adicional
///
/// **Estados:**
/// - [CorteInitial]: Estado inicial antes de iniciar el corte
/// - [CorteCountInput]: Pantalla de ingreso de efectivo contado
/// - [CorteSummaryView]: Resumen del corte con diferencia calculada
/// - [CorteSuccess]: Corte completado, ticket generado
/// - [CorteValidationError]: Error de validación en efectivo contado
/// - [CorteError]: Error al escribir en Local_DB
///
/// **Eventos:**
/// - [CorteInitiated]: Inicia el proceso de corte
/// - [CashCountEntered]: Efectivo contado ingresado
/// - [CorteConfirmed]: Cajero confirma el corte
/// - [CorteRejected]: Cajero rechaza el corte
///
/// **Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.8, 9.9**
class CorteBloc extends Bloc<CorteEvent, CorteState> {
  final CloseSessionUseCase _closeSessionUseCase;
  final GetShiftSummaryUseCase _getShiftSummaryUseCase;

  CorteBloc({
    required CloseSessionUseCase closeSessionUseCase,
    required GetShiftSummaryUseCase getShiftSummaryUseCase,
  }) : _closeSessionUseCase = closeSessionUseCase,
       _getShiftSummaryUseCase = getShiftSummaryUseCase,
       super(const CorteInitial()) {
    on<CorteInitiated>(_onCorteInitiated);
    on<CashCountEntered>(_onCashCountEntered);
    on<CorteConfirmed>(_onCorteConfirmed);
    on<CorteRejected>(_onCorteRejected);
  }

  /// Maneja [CorteInitiated]
  ///
  /// 1. Obtiene el resumen del turno actual usando [GetShiftSummaryUseCase]
  /// 2. Verifica si el turno tiene transacciones registradas
  /// 3. Emite [CorteCountInput] con el resumen y flag de turno vacío
  /// 4. Si falla la consulta: emite [CorteError]
  ///
  /// **Comportamiento Offline-First:**
  /// - El resumen se calcula desde Local_DB, funciona sin conectividad
  /// - Incluye transacciones con is_synced = false
  ///
  /// **Validates: Requirements 9.1, 9.8, 10.1**
  Future<void> _onCorteInitiated(
    CorteInitiated event,
    Emitter<CorteState> emit,
  ) async {
    // Obtener el resumen del turno actual
    final result = await _getShiftSummaryUseCase(
      GetShiftSummaryParams(sessionId: event.sessionId),
    );

    result.fold(
      (failure) {
        // Error al obtener el resumen del turno
        emit(CorteError(message: failure.message));
      },
      (shiftSummary) {
        // Verificar si el turno tiene transacciones
        final hasNoTransactions = shiftSummary.isEmpty;

        // Emitir estado de entrada de efectivo contado
        emit(
          CorteCountInput(
            sessionId: event.sessionId,
            shiftSummary: shiftSummary,
            hasNoTransactions: hasNoTransactions,
          ),
        );
      },
    );
  }

  /// Maneja [CashCountEntered]
  ///
  /// 1. Valida que el efectivo contado esté en el rango válido (0.00–999,999.99)
  /// 2. Si la validación falla: emite [CorteValidationError]
  /// 3. Si la validación es exitosa:
  ///    - Calcula la diferencia: countedCash - expectedCash
  ///    - Emite [CorteSummaryView] con el resumen y diferencia calculada
  ///
  /// **Validaciones aplicadas (Requirement 9.2):**
  /// - No negativo
  /// - No superior a 999,999.99
  ///
  /// **Validates: Requirements 9.1, 9.2, 9.3**
  Future<void> _onCashCountEntered(
    CashCountEntered event,
    Emitter<CorteState> emit,
  ) async {
    // El estado actual debe ser CorteCountInput
    if (state is! CorteCountInput) {
      emit(
        const CorteError(
          message: 'Estado inválido para ingresar efectivo contado',
        ),
      );
      return;
    }

    final currentState = state as CorteCountInput;

    // Validar el efectivo contado (0.00–999,999.99)
    if (event.countedCash < 0.0) {
      emit(
        const CorteValidationError(
          message: 'El efectivo contado no puede ser negativo',
        ),
      );
      // Regresar al estado anterior para que el cajero pueda corregir
      emit(currentState);
      return;
    }

    if (event.countedCash > 999999.99) {
      emit(
        const CorteValidationError(
          message: 'El efectivo contado no puede exceder \$999,999.99',
        ),
      );
      // Regresar al estado anterior para que el cajero pueda corregir
      emit(currentState);
      return;
    }

    // Calcular la diferencia
    // expectedCash viene del shiftSummary
    final expectedCash = currentState.shiftSummary.expectedCash;
    final difference = event.countedCash - expectedCash;

    // Emitir estado de resumen del corte
    emit(
      CorteSummaryView(
        sessionId: currentState.sessionId,
        shiftSummary: currentState.shiftSummary,
        countedCash: event.countedCash,
        expectedCash: expectedCash,
        difference: difference,
        hasNoTransactions: currentState.hasNoTransactions,
      ),
    );
  }

  /// Maneja [CorteConfirmed]
  ///
  /// 1. Llama a [CloseSessionUseCase] para cerrar la sesión y registrar el corte
  /// 2. El use case valida el efectivo contado y registra en Local_DB
  /// 3. Si exitoso: emite [CorteSuccess] con la sesión cerrada y el ticket
  /// 4. Si falla: emite [CorteError]
  ///
  /// **Comportamiento Offline-First:**
  /// - El corte se registra en Local_DB con is_synced = false
  /// - SyncService sincroniza con el backend en el siguiente ciclo de 5 min
  /// - La operación nunca falla por falta de conectividad
  ///
  /// **Validates: Requirements 9.3, 9.4, 10.1, 10.2**
  Future<void> _onCorteConfirmed(
    CorteConfirmed event,
    Emitter<CorteState> emit,
  ) async {
    // El estado actual debe ser CorteSummaryView
    if (state is! CorteSummaryView) {
      emit(
        const CorteError(message: 'Estado inválido para confirmar el corte'),
      );
      return;
    }

    final currentState = state as CorteSummaryView;

    // Cerrar la sesión usando CloseSessionUseCase
    final result = await _closeSessionUseCase(
      CloseSessionUseCaseParams(
        sessionId: currentState.sessionId,
        countedCash: event.countedCash,
      ),
    );

    result.fold(
      (failure) {
        // Error al cerrar la sesión
        emit(CorteError(message: failure.message));
        // Regresar al estado anterior para que el cajero pueda reintentar
        emit(currentState);
      },
      (closedSession) {
        // Éxito: sesión cerrada y corte registrado
        // Emitir estado de éxito con el ticket digital
        emit(
          CorteSuccess(
            session: closedSession,
            shiftSummary: currentState.shiftSummary,
          ),
        );
      },
    );
  }

  /// Maneja [CorteRejected]
  ///
  /// El cajero ha decidido no completar el corte y regresar al Modo_Cajero.
  /// No se escribe ningún dato en Local_DB. La sesión permanece abierta.
  ///
  /// Emite [CorteInitial] para resetear el estado del BLoC.
  ///
  /// **Validates: Requirement 9.9**
  Future<void> _onCorteRejected(
    CorteRejected event,
    Emitter<CorteState> emit,
  ) async {
    // Resetear el estado a inicial
    // La navegación al CajeroHomePage se maneja en el widget
    emit(const CorteInitial());
  }
}
