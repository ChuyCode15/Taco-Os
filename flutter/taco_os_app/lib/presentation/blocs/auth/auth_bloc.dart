import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/usecases/auth/check_session_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_event.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_state.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// BLoC que gestiona el ciclo de vida de autenticación del usuario
///
/// Flujo de login en 2 pasos:
/// 1. GoogleSignInRequested → Google Auth → GoogleAuthenticated
/// 2. VerifyUserRequested → Backend /verificar → UserVerified | UserNotFound
///    - UserVerified → navegar al dashboard
///    - UserNotFound → navegar a registro → RegisterUserRequested → Authenticated
///
/// **Validates: Requirements 1.1, 1.3, 1.5, 1.6, 1.7, 1.9**
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final CheckSessionUseCase checkSessionUseCase;
  final IAuthRepository authRepository;

  int _failedAttempts = 0;
  bool _isBlocked = false;
  Timer? _blockTimer;
  Timer? _countdownTimer;
  int _blockedSecondsRemaining = 0;

  AuthBloc({
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.checkSessionUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<VerifyUserRequested>(_onVerifyUserRequested);
    on<RegisterUserRequested>(_onRegisterUserRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<SessionChecked>(_onSessionChecked);
    on<BackgroundTimeoutExceeded>(_onBackgroundTimeoutExceeded);
    on<UnblockRequested>(_onUnblockRequested);
  }

  // ── PASO 1: Google Sign-In ────────────────────────────────────────────────

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isBlocked) {
      emit(AuthError(
        message: 'Demasiados intentos fallidos. Intenta nuevamente en $_blockedSecondsRemaining segundos.',
        isBlocked: true,
        blockedSecondsRemaining: _blockedSecondsRemaining,
      ));
      return;
    }

    emit(const AuthLoading());

    final result = await authRepository.signInWithGoogleOnly();

    result.fold(
      (failure) {
        if (failure is AuthCancelledFailure) {
          emit(const Unauthenticated());
          return;
        }
        _handleFailure(failure, emit);
      },
      (googleData) {
        _failedAttempts = 0;
        _cancelTimers();
        emit(GoogleAuthenticated(
          idGoogle: googleData['idGoogle'] as String,
          email: googleData['email'] as String,
          displayName: googleData['displayName'] as String,
        ));
      },
    );
  }

  // ── PASO 2: Verify user in backend ────────────────────────────────────────

  Future<void> _onVerifyUserRequested(
    VerifyUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.verifyUser(event.idGoogle);

    final failureOrNull = result.fold((f) => f, (_) => null);
    if (failureOrNull != null) {
      _handleFailure(failureOrNull, emit);
      return;
    }

    final authResult = result.getRight().toNullable()!;
    _failedAttempts = 0;
    _cancelTimers();

    if (authResult.existe && authResult.token != null) {
      final userResult = await authRepository.storeTokenAndParseUser(
        token: authResult.token!,
        fallbackEmail: event.email,
        fallbackDisplayName: event.displayName,
      );
      userResult.fold(
        (failure) => _handleFailure(failure, emit),
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(UserNotFound(
        idGoogle: event.idGoogle,
        email: event.email,
        displayName: event.displayName,
      ));
    }
  }

  // ── PASO 3: Register new user ─────────────────────────────────────────────

  Future<void> _onRegisterUserRequested(
    RegisterUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.registerUser(
      idGoogle: event.idGoogle,
      nickname: event.nickname,
      email: event.email,
      role: event.role,
    );

    final failureOrNull = result.fold((f) => f, (_) => null);
    if (failureOrNull != null) {
      _handleFailure(failureOrNull, emit);
      return;
    }

    final authResult = result.getRight().toNullable()!;
    _failedAttempts = 0;
    _cancelTimers();

    if (authResult.token != null) {
      final userResult = await authRepository.storeTokenAndParseUser(
        token: authResult.token!,
        fallbackEmail: event.email,
        fallbackDisplayName: event.nickname,
      );
      userResult.fold(
        (failure) => _handleFailure(failure, emit),
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(const AuthError(message: 'No se pudo registrar el usuario'));
    }
  }

  // ── Legacy full flow ──────────────────────────────────────────────────────

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isBlocked) {
      emit(AuthError(
        message: 'Demasiados intentos fallidos. Intenta nuevamente en $_blockedSecondsRemaining segundos.',
        isBlocked: true,
        blockedSecondsRemaining: _blockedSecondsRemaining,
      ));
      return;
    }

    emit(const AuthLoading());

    final result = await signInUseCase(
      SignInParams(isRegistration: event.isRegistration),
    );

    result.fold(
      (failure) {
        if (failure is AuthCancelledFailure) {
          emit(const Unauthenticated());
          return;
        }
        _handleFailure(failure, emit);
      },
      (user) {
        _failedAttempts = 0;
        _cancelTimers();
        emit(Authenticated(user: user));
      },
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signOutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: 'Error al cerrar sesión: ${failure.message}')),
      (_) {
        _failedAttempts = 0;
        _cancelTimers();
        emit(const Unauthenticated());
      },
    );
  }

  // ── Session check ─────────────────────────────────────────────────────────

  Future<void> _onSessionChecked(
    SessionChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await checkSessionUseCase(
      CheckSessionParams(backgroundTimeMs: event.backgroundTimeMs),
    );
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onBackgroundTimeoutExceeded(
    BackgroundTimeoutExceeded event,
    Emitter<AuthState> emit,
  ) async {
    await signOutUseCase(const NoParams());
    emit(const Unauthenticated());
  }

  Future<void> _onUnblockRequested(
    UnblockRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Unauthenticated());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _handleFailure(Failure failure, Emitter<AuthState> emit) {
    _failedAttempts++;
    if (_failedAttempts >= 3) {
      _startBlockTimer(emit);
      emit(AuthError(
        message: _getFailureMessage(failure),
        isBlocked: true,
        blockedSecondsRemaining: _blockedSecondsRemaining,
      ));
    } else {
      emit(AuthError(
        message: '${_getFailureMessage(failure)} (Intento $_failedAttempts de 3)',
        isBlocked: false,
      ));
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure) {
      case NetworkFailure():
        return 'Sin conexión a internet. Verifica tu conexión WiFi o datos móviles.';
      case BackendUnavailableFailure():
        return 'No se puede conectar con el servidor. Verifica que el backend esté activo.';
      case TimeoutFailure():
        return 'La conexión está tardando demasiado. Verifica tu conexión e intenta de nuevo.';
      case ServerFailure():
        return 'Error del servidor. Intenta nuevamente más tarde.';
      case AuthFailure():
        return 'Error al iniciar sesión con Google. Intenta nuevamente.';
      case ValidationFailure():
        return failure.message;
      default:
        return 'Error inesperado: ${failure.message}';
    }
  }

  void _startBlockTimer(Emitter<AuthState> emit) {
    _isBlocked = true;
    _blockedSecondsRemaining = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) { timer.cancel(); return; }
      _blockedSecondsRemaining--;
      if (_blockedSecondsRemaining <= 0) {
        timer.cancel();
        _isBlocked = false;
        _failedAttempts = 0;
        _blockTimer?.cancel();
        _blockTimer = null;
        _countdownTimer = null;
        add(const UnblockRequested());
        return;
      }
      emit(AuthError(
        message: 'Demasiados intentos fallidos. Intenta nuevamente en $_blockedSecondsRemaining segundos.',
        isBlocked: true,
        blockedSecondsRemaining: _blockedSecondsRemaining,
      ));
    });
  }

  void _cancelTimers() {
    _blockTimer?.cancel();
    _blockTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
