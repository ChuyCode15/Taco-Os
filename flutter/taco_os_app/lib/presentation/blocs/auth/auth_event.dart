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

/// Evento disparado cuando el usuario solicita iniciar sesión con Google
///
/// **Validates: Requirements 1.1, 1.3, 1.5**
///
/// Este evento inicia el flujo de autenticación de Google Sign-In.
/// El AuthBloc manejará:
/// - Contador de intentos fallidos (máximo 3)
/// - Bloqueo de 30 segundos tras 3 fallos consecutivos
/// - Almacenamiento del JWT en éxito
/// - Flag isRegistration para indicar si es un nuevo registro o login
class SignInRequested extends AuthEvent {
  /// Indica si el usuario está registrándose (true) o iniciando sesión (false)
  final bool isRegistration;

  const SignInRequested({this.isRegistration = false});

  @override
  List<Object?> get props => [isRegistration];
}

/// Evento disparado cuando el usuario solicita cerrar sesión
///
/// **Validates: Requirements 1.9**
///
/// Este evento elimina el JWT del almacenamiento seguro y limpia
/// los datos de identidad y rol del usuario de la memoria.
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Evento disparado para verificar la sesión activa
///
/// **Validates: Requirements 1.6, 1.7, 1.8**
///
/// Este evento verifica:
/// - Validez del JWT (no expirado)
/// - Tiempo en segundo plano (< 12 horas)
///
/// Si alguna condición falla, invalida la sesión y requiere re-autenticación.
class SessionChecked extends AuthEvent {
  /// Tiempo en milisegundos que la app ha estado en segundo plano
  final int backgroundTimeMs;

  const SessionChecked({required this.backgroundTimeMs});

  @override
  List<Object?> get props => [backgroundTimeMs];
}

/// Evento disparado cuando el turno lleva más de 12 horas en segundo plano
///
/// **Validates: Requirements 1.7**
///
/// Este evento se dispara automáticamente cuando se detecta que la app
/// ha estado en segundo plano por más de 12 horas. Invalida la sesión
/// local, elimina el JWT y emite [Unauthenticated].
class BackgroundTimeoutExceeded extends AuthEvent {
  const BackgroundTimeoutExceeded();
}

/// Evento disparado cuando el timer de bloqueo expira
///
/// **Validates: Requirements 1.5**
///
/// Este evento se dispara automáticamente cuando el timer de 30 segundos
/// expira después de 3 intentos fallidos. Desbloquea los botones de login
/// y permite que el usuario intente nuevamente.
class UnblockRequested extends AuthEvent {
  const UnblockRequested();
}
