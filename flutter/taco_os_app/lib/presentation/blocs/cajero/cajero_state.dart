import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';

/// Estados del CajeroBloc
///
/// Representa el estado del turno del cajero: inicial, cargando, activo,
/// cerrado o error. La navegación depende de estos estados.
///
/// **Validates: Requirements 3.1, 3.2, 3.5**
sealed class CajeroState extends Equatable {
  const CajeroState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cargar o abrir una sesión
///
/// La aplicación muestra la pantalla de apertura de caja si no hay turno activo.
class CajeroInitial extends CajeroState {
  const CajeroInitial();
}

/// Estado de carga durante operaciones asíncronas
///
/// Se emite mientras se abre, cierra o carga una sesión desde Local_DB.
class CajeroLoading extends CajeroState {
  const CajeroLoading();
}

/// Estado cuando hay un turno activo (sesión abierta)
///
/// Permite el acceso al Modo_Cajero (3 botones: Ventas, Gastos, ¿Cómo voy?).
/// Contiene la [CashSession] activa con todos sus datos.
///
/// **Validates: Requirements 3.2, 3.5, 4.1**
class TurnoActivo extends CajeroState {
  final CashSession session;

  const TurnoActivo({required this.session});

  @override
  List<Object?> get props => [session];
}

/// Estado cuando el turno ha sido cerrado (después del Corte)
///
/// La aplicación debe redirigir a la pantalla de apertura de caja
/// para iniciar un nuevo turno.
///
/// **Validates: Requirement 9.6**
class TurnoCerrado extends CajeroState {
  const TurnoCerrado();
}

/// Estado de error cuando falla una operación de sesión
///
/// Muestra el mensaje de error al usuario sin bloquear la aplicación.
/// El cajero puede reintentar la operación.
///
/// **Validates: Requirements 3.3, 9.3 (error handling)**
class CajeroError extends CajeroState {
  final String message;

  const CajeroError({required this.message});

  @override
  List<Object?> get props => [message];
}
