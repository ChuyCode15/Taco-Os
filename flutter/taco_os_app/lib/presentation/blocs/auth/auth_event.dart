import 'package:equatable/equatable.dart';

/// Eventos del [AuthBloc] que representan acciones de autenticación
///
/// Cada evento corresponde a una interacción del usuario o cambio de estado
/// del ciclo de vida de la aplicación relacionado con la autenticación.
///
/// **Validates: Requirements 1.1, 1.6, 1.7, 1.9**
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// PASO 1: Ejecuta Google Sign-In y obtiene las credenciales del usuario.
///
/// No llama al backend. Solo obtiene idGoogle, email, displayName.
/// Si es exitoso, emite [GoogleAuthenticated].
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// PASO 2: Verifica si el usuario de Google ya existe en el backend.
///
/// Llama GET /auth/verificar/{idGoogle}.
/// Si existe: emite [UserVerified] con JWT y datos.
/// Si no existe: emite [UserNotFound] para ir a registro.
class VerifyUserRequested extends AuthEvent {
  final String idGoogle;
  final String email;
  final String displayName;

  const VerifyUserRequested({
    required this.idGoogle,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object?> get props => [idGoogle, email, displayName];
}

/// Registra un usuario nuevo en el backend.
///
/// Llama POST /auth/registrar con los datos del usuario.
/// Al éxito, emite [Authenticated] con el JWT y datos.
class RegisterUserRequested extends AuthEvent {
  final String idGoogle;
  final String nickname;
  final String email;
  final String role;

  const RegisterUserRequested({
    required this.idGoogle,
    required this.nickname,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [idGoogle, nickname, email, role];
}

/// Evento legacy: Flujo completo de Google Sign-In + verificar/registrar
class SignInRequested extends AuthEvent {
  final bool isRegistration;

  const SignInRequested({this.isRegistration = false});

  @override
  List<Object?> get props => [isRegistration];
}

/// Evento disparado cuando el usuario solicita cerrar sesión
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Evento disparado para verificar la sesión activa
class SessionChecked extends AuthEvent {
  final int backgroundTimeMs;

  const SessionChecked({required this.backgroundTimeMs});

  @override
  List<Object?> get props => [backgroundTimeMs];
}

/// Evento disparado cuando el turno lleva más de 12 horas en segundo plano
class BackgroundTimeoutExceeded extends AuthEvent {
  const BackgroundTimeoutExceeded();
}

/// Evento disparado cuando el timer de bloqueo expira
class UnblockRequested extends AuthEvent {
  const UnblockRequested();
}
