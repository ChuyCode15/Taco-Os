import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/open_session_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';

/// BLoC para gestionar el ciclo de vida del turno del cajero
///
/// Maneja los eventos de apertura, cierre y carga de sesión desde Local_DB.
/// Usa [OpenSessionUseCase] y [ISessionRepository] sin acceder directamente
/// a la capa de infraestructura (Clean Architecture).
///
/// **Estados:**
/// - [CajeroInitial]: Estado inicial sin sesión
/// - [CajeroLoading]: Operación en progreso
/// - [TurnoActivo]: Sesión abierta, permite acceso al Modo_Cajero
/// - [TurnoCerrado]: Sesión cerrada, redirige a apertura
/// - [CajeroError]: Error en operación, muestra mensaje
///
/// **Eventos:**
/// - [OpenSessionRequested]: Abre nueva sesión con Fondo_de_Cambio
/// - [CloseSessionRequested]: Cierra sesión con efectivo contado (Corte)
/// - [SessionLoaded]: Carga sesión activa desde Local_DB al iniciar
///
/// **Validates: Requirements 3.1, 3.2, 3.5, 9.6**
class CajeroBloc extends Bloc<CajeroEvent, CajeroState> {
  final OpenSessionUseCase _openSessionUseCase;
  final ISessionRepository _sessionRepository;

  CajeroBloc({
    required OpenSessionUseCase openSessionUseCase,
    required ISessionRepository sessionRepository,
  }) : _openSessionUseCase = openSessionUseCase,
       _sessionRepository = sessionRepository,
       super(const CajeroInitial()) {
    on<OpenSessionRequested>(_onOpenSessionRequested);
    on<CloseSessionRequested>(_onCloseSessionRequested);
    on<SessionLoaded>(_onSessionLoaded);
  }

  /// Maneja [OpenSessionRequested]
  ///
  /// 1. Emite [CajeroLoading]
  /// 2. Llama a [OpenSessionUseCase] con validación incluida
  /// 3. Si exitoso: emite [TurnoActivo] con la sesión creada
  /// 4. Si falla: emite [CajeroError] con el mensaje de error
  ///
  /// **Validates: Requirements 3.2, 3.3, 3.6, 3.7**
  Future<void> _onOpenSessionRequested(
    OpenSessionRequested event,
    Emitter<CajeroState> emit,
  ) async {
    emit(const CajeroLoading());

    final result = await _openSessionUseCase(
      OpenSessionUseCaseParams(
        businessId: event.businessId,
        userId: event.userId,
        initialCash: event.initialCash,
      ),
    );

    result.fold(
      (failure) => emit(CajeroError(message: failure.message)),
      (session) => emit(TurnoActivo(session: session)),
    );
  }

  /// Maneja [CloseSessionRequested]
  ///
  /// 1. Emite [CajeroLoading]
  /// 2. Llama a [ISessionRepository.closeSession] con el monto contado
  /// 3. Si exitoso: emite [TurnoCerrado]
  /// 4. Si falla: emite [CajeroError] con el mensaje de error
  ///
  /// **Validates: Requirements 9.3, 9.4, 9.6**
  Future<void> _onCloseSessionRequested(
    CloseSessionRequested event,
    Emitter<CajeroState> emit,
  ) async {
    emit(const CajeroLoading());

    final result = await _sessionRepository.closeSession(
      CloseSessionParams(
        sessionId: event.sessionId,
        countedCash: event.countedCash,
      ),
    );

    result.fold(
      (failure) => emit(CajeroError(message: failure.message)),
      (session) => emit(const TurnoCerrado()),
    );
  }

  /// Maneja [SessionLoaded]
  ///
  /// 1. Emite [CajeroLoading]
  /// 2. Llama a [ISessionRepository.getActiveSession] para recuperar turno activo
  /// 3. Si hay sesión activa: emite [TurnoActivo]
  /// 4. Si no hay sesión: emite [TurnoCerrado]
  /// 5. Si falla: emite [CajeroError]
  ///
  /// **Validates: Requirements 3.5, 15.2 (filtrado por business_id)**
  Future<void> _onSessionLoaded(
    SessionLoaded event,
    Emitter<CajeroState> emit,
  ) async {
    emit(const CajeroLoading());

    final result = await _sessionRepository.getActiveSession(event.businessId);

    result.fold((failure) => emit(CajeroError(message: failure.message)), (
      session,
    ) {
      if (session != null && session.isActive) {
        emit(TurnoActivo(session: session));
      } else {
        emit(const TurnoCerrado());
      }
    });
  }
}
