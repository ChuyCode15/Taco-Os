import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/user.dart';

/// Estados del [AuthBloc] que representan el ciclo de vida de autenticación
///
/// Cada estado refleja la situación actual del usuario respecto a la autenticación
/// y se usa para renderizar la UI apropiada.
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.6, 1.7, 1.9**
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de verificar la sesión
///
/// Este estado se emite cuando la app se inicia y aún no se ha
/// verificado si existe una sesión activa válida.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga durante operaciones de autenticación
///
/// Se emite durante:
/// - El flujo de Google Sign-In
/// - La verificación de sesión
/// - El cierre de sesión
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado de usuario autenticado exitosamente
///
/// **Validates: Requirements 1.2, 1.6**
///
/// Este estado se emite cuando:
/// - El usuario completa exitosamente el Google Sign-In
/// - La sesión es válida (JWT no expirado y < 12h en segundo plano)
class Authenticated extends AuthState {
  /// Usuario autenticado con su perfil y rol
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado de usuario no autenticado
///
/// **Validates: Requirements 1.7, 1.8, 1.9**
///
/// Este estado se emite cuando:
/// - No hay sesión activa al iniciar la app
/// - El JWT ha expirado
/// - El tiempo en segundo plano superó las 12 horas
/// - El usuario cierra sesión manualmente
/// - El usuario cancela el flujo de Google Sign-In (sin mostrar error)
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado de error en la autenticación
///
/// **Validates: Requirements 1.3, 1.5**
///
/// Este estado se emite cuando:
/// - El Google Sign-In falla (error de red, credenciales inválidas)
/// - Se alcanza el límite de 3 intentos fallidos consecutivos
/// - Ocurre un error inesperado durante la autenticación
class AuthError extends AuthState {
  /// Mensaje de error descriptivo para mostrar al usuario
  final String message;

  /// Indica si el botón de inicio de sesión está bloqueado
  /// por haber alcanzado el límite de 3 intentos fallidos
  final bool isBlocked;

  /// Tiempo restante en segundos del bloqueo (si isBlocked = true)
  final int? blockedSecondsRemaining;

  const AuthError({
    required this.message,
    this.isBlocked = false,
    this.blockedSecondsRemaining,
  });

  @override
  List<Object?> get props => [message, isBlocked, blockedSecondsRemaining];
}
