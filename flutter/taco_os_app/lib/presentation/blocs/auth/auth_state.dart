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
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga durante operaciones de autenticación
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// PASO 1 COMPLETADO: Google Sign-In exitoso.
///
/// Contiene las credenciales de Google (idGoogle, email, displayName).
/// El siguiente paso es llamar al backend para verificar si el usuario existe.
class GoogleAuthenticated extends AuthState {
  final String idGoogle;
  final String email;
  final String displayName;

  const GoogleAuthenticated({
    required this.idGoogle,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object?> get props => [idGoogle, email, displayName];
}

/// PASO 2 COMPLETADO (usuario existe): Backend verificó que el usuario tiene cuenta.
///
/// Contiene el JWT y los datos del usuario. Listo para navegar al dashboard.
class UserVerified extends AuthState {
  final User user;

  const UserVerified({required this.user});

  @override
  List<Object?> get props => [user];
}

/// PASO 2 COMPLETADO (usuario nuevo): Backend indica que el usuario no existe.
///
/// Contiene los datos de Google para pre-llenar el formulario de registro.
/// El siguiente paso es llamar a /auth/registrar.
class UserNotFound extends AuthState {
  final String idGoogle;
  final String email;
  final String displayName;

  const UserNotFound({
    required this.idGoogle,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object?> get props => [idGoogle, email, displayName];
}

/// Estado de usuario autenticado exitosamente
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado de usuario no autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado de error en la autenticación
class AuthError extends AuthState {
  final String message;
  final bool isBlocked;
  final int? blockedSecondsRemaining;

  const AuthError({
    required this.message,
    this.isBlocked = false,
    this.blockedSecondsRemaining,
  });

  @override
  List<Object?> get props => [message, isBlocked, blockedSecondsRemaining];
}
