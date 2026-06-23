import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/usecases/auth/check_session_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_event.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_state.dart';

/// BLoC que gestiona el ciclo de vida de autenticación del usuario
///
/// Maneja:
/// - Google Sign-In con bloqueo tras 3 intentos fallidos
/// - Validación de sesión (JWT + tiempo en segundo plano)
/// - Cierre de sesión
/// - Timeout de 12 horas en segundo plano
///
/// **Validates: Requirements 1.1, 1.3, 1.5, 1.6, 1.7, 1.9**
///
/// **Reglas de bloqueo:**
/// - Máximo 3 intentos fallidos consecutivos
/// - Bloqueo de 30 segundos tras 3 fallos
/// - El contador se reinicia al éxito o tras expirar el bloqueo
///
/// **Reglas de sesión:**
/// - JWT válido (no expirado)
/// - Tiempo en segundo plano < 12 horas
/// - Si alguna condición falla, invalida la sesión
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final CheckSessionUseCase checkSessionUseCase;

  /// Contador de intentos fallidos consecutivos de sign-in
  int _failedAttempts = 0;

  /// Indica si el botón de sign-in está bloqueado
  bool _isBlocked = false;

  /// Timer para el bloqueo de 30 segundos
  Timer? _blockTimer;

  /// Timer para la cuenta regresiva visual del bloqueo
  Timer? _countdownTimer;

  /// Segundos restantes del bloqueo actual
  int _blockedSecondsRemaining = 0;

  AuthBloc({
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.checkSessionUseCase,
  }) : super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<SessionChecked>(_onSessionChecked);
    on<BackgroundTimeoutExceeded>(_onBackgroundTimeoutExceeded);
    on<UnblockRequested>(_onUnblockRequested);
  }

  /// Maneja el evento de desbloqueo después de que expire el timer
  ///
  /// **Validates: Requirements 1.5**
  ///
  /// Este evento se dispara automáticamente cuando el timer de 30 segundos
  /// expira, desbloqueando los botones y permitiendo nuevos intentos de login.
  Future<void> _onUnblockRequested(
    UnblockRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emitir estado Unauthenticated para desbloquear los botones
    emit(const Unauthenticated());
  }

  /// Maneja el evento de solicitud de inicio de sesión
  ///
  /// **Validates: Requirements 1.1, 1.3, 1.5**
  ///
  /// Flujo:
  /// 1. Verifica si el botón está bloqueado por 3 intentos fallidos
  /// 2. Si está bloqueado, emite [AuthError] con contador de tiempo
  /// 3. Si no está bloqueado, ejecuta el SignInUseCase
  /// 4. En éxito: reinicia contador de intentos y emite [Authenticated]
  /// 5. En fallo: incrementa contador de intentos
  /// 6. Si llega a 3 intentos: activa bloqueo de 30 segundos
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    // AC 1.5: Bloquear el botón durante 30 segundos tras 3 intentos fallidos
    if (_isBlocked) {
      emit(
        AuthError(
          message:
              'Demasiados intentos fallidos. Intenta nuevamente en $_blockedSecondsRemaining segundos.',
          isBlocked: true,
          blockedSecondsRemaining: _blockedSecondsRemaining,
        ),
      );
      return;
    }

    emit(const AuthLoading());

    final result = await signInUseCase(
      SignInParams(isRegistration: event.isRegistration),
    );

    result.fold(
      (failure) {
        // AC 1.4: Si el usuario cancela el Google Sign-In, no mostrar error
        // y regresar a Unauthenticated silenciosamente
        if (failure is AuthCancelledFailure) {
          // No incrementar contador de intentos, no mostrar error
          emit(const Unauthenticated());
          return;
        }

        // Incrementar contador de intentos fallidos
        _failedAttempts++;

        // AC 1.3: Máximo 3 intentos consecutivos
        if (_failedAttempts >= 3) {
          _startBlockTimer(emit);
          emit(
            AuthError(
              message: _getFailureMessage(failure),
              isBlocked: true,
              blockedSecondsRemaining: _blockedSecondsRemaining,
            ),
          );
        } else {
          // AC 1.3: Mostrar mensaje descriptivo y permitir reintentar
          emit(
            AuthError(
              message:
                  '${_getFailureMessage(failure)} (Intento $_failedAttempts de 3)',
              isBlocked: false,
            ),
          );
        }
      },
      (user) {
        // AC 1.2: Autenticación exitosa
        // Reiniciar contador de intentos fallidos
        _failedAttempts = 0;
        _cancelTimers();

        emit(Authenticated(user: user));
      },
    );
  }

  /// Maneja el evento de solicitud de cierre de sesión
  ///
  /// **Validates: Requirements 1.9**
  ///
  /// Flujo:
  /// 1. Ejecuta el SignOutUseCase
  /// 2. El use case elimina el JWT del almacenamiento seguro
  /// 3. El use case limpia los datos de identidad de memoria
  /// 4. Emite [Unauthenticated]
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) {
        // Raramente falla el sign-out, pero manejamos el caso
        emit(AuthError(message: 'Error al cerrar sesión: ${failure.message}'));
      },
      (_) {
        // AC 1.9: Sesión cerrada exitosamente
        _failedAttempts = 0; // Reiniciar contador al cerrar sesión
        _cancelTimers();
        emit(const Unauthenticated());
      },
    );
  }

  /// Maneja el evento de verificación de sesión
  ///
  /// **Validates: Requirements 1.6, 1.7, 1.8**
  ///
  /// Flujo:
  /// 1. Ejecuta el CheckSessionUseCase con el tiempo en segundo plano
  /// 2. El use case valida JWT y tiempo en background
  /// 3. Si la sesión es válida, emite [Authenticated]
  /// 4. Si la sesión es inválida, emite [Unauthenticated]
  Future<void> _onSessionChecked(
    SessionChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkSessionUseCase(
      CheckSessionParams(backgroundTimeMs: event.backgroundTimeMs),
    );

    result.fold(
      (failure) {
        // Error al verificar la sesión (JWT inválido, etc.)
        // AC 1.8: JWT expirado invalida la sesión
        emit(const Unauthenticated());
      },
      (user) {
        if (user != null) {
          // AC 1.6: Sesión válida (JWT no expirado y < 12h en background)
          emit(Authenticated(user: user));
        } else {
          // AC 1.7, 1.8: Sesión inválida (JWT expiró o > 12h en background)
          emit(const Unauthenticated());
        }
      },
    );
  }

  /// Maneja el evento de timeout por tiempo en segundo plano excedido
  ///
  /// **Validates: Requirements 1.7**
  ///
  /// Este evento se dispara cuando se detecta que la app ha estado en
  /// segundo plano por más de 12 horas. Elimina el JWT y emite [Unauthenticated].
  Future<void> _onBackgroundTimeoutExceeded(
    BackgroundTimeoutExceeded event,
    Emitter<AuthState> emit,
  ) async {
    // AC 1.7: Invalidar sesión tras 12h en segundo plano
    // Ejecutar signOut para eliminar el JWT
    await signOutUseCase(const NoParams());

    emit(const Unauthenticated());
  }

  /// Inicia el timer de bloqueo de 30 segundos
  ///
  /// **Validates: Requirements 1.5**
  ///
  /// El bloqueo se activa tras 3 intentos fallidos consecutivos.
  /// Durante los 30 segundos, el botón de sign-in permanece deshabilitado
  /// y se muestra una cuenta regresiva al usuario.
  void _startBlockTimer(Emitter<AuthState> emit) {
    _isBlocked = true;
    _blockedSecondsRemaining = 30;

    // Timer de cuenta regresiva (actualiza cada segundo)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      _blockedSecondsRemaining--;

      // Si ya expiró el bloqueo, desbloquear y emitir Unauthenticated
      if (_blockedSecondsRemaining <= 0) {
        timer.cancel();
        _isBlocked = false;
        _failedAttempts = 0;
        _blockTimer?.cancel();
        _blockTimer = null;
        _countdownTimer = null;

        // Emitir estado desbloqueado para que los botones se reactiven
        add(const UnblockRequested());
        return;
      }

      // Emitir estado actualizado con la cuenta regresiva
      emit(
        AuthError(
          message:
              'Demasiados intentos fallidos. Intenta nuevamente en $_blockedSecondsRemaining segundos.',
          isBlocked: true,
          blockedSecondsRemaining: _blockedSecondsRemaining,
        ),
      );
    });
  }

  /// Cancela todos los timers activos
  void _cancelTimers() {
    _blockTimer?.cancel();
    _blockTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Mapea un [Failure] a un mensaje de error descriptivo para el usuario
  ///
  /// **Validates: Requirements 1.3**
  String _getFailureMessage(Failure failure) {
    switch (failure) {
      case NetworkFailure():
        return '📡 Sin conexión a internet. Verifica tu conexión WiFi o datos móviles.';
      case BackendUnavailableFailure():
        return '🔌 No se puede conectar con el servidor. Verifica que el backend esté activo o contacta al administrador.';
      case TimeoutFailure():
        return '⏱️ La conexión está tardando demasiado. Verifica tu conexión e intenta de nuevo.';
      case ServerFailure():
        return '⚠️ Error del servidor. Intenta nuevamente más tarde.';
      case AuthFailure():
        return '🔒 Error al iniciar sesión con Google. Intenta nuevamente.';
      case ValidationFailure():
        return '⚠️ ${failure.message}';
      default:
        return '❌ Error inesperado: ${failure.message}';
    }
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
