import 'package:equatable/equatable.dart';

/// Eventos del PatronBloc
///
/// Define todos los eventos que el Patron puede disparar desde el Dashboard:
/// - Cargar ventas del día
/// - Cargar reportes por rango de fechas
/// - Cargar equipo (Cajeros vinculados)
/// - Cargar notificaciones no leídas
///
/// Validado por Requirement 12.1: Dashboard del Patron
/// Validado por Requirement 12.2: Sección Ventas
/// Validado por Requirement 12.3: Sección Reportes
/// Validado por Requirement 12.4: Sección Equipo
/// Validado por Requirement 12.5: Badge de notificaciones
abstract class PatronEvent extends Equatable {
  const PatronEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar las ventas del día actual
///
/// El Patron solicita el resumen de ventas del día: número de transacciones,
/// total de ventas y desglose por método de pago (efectivo y tarjeta).
///
/// Validado por Requirement 12.2: Acceso a sección Ventas
class LoadTodaySalesRequested extends PatronEvent {
  final String businessId;

  const LoadTodaySalesRequested(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

/// Evento para cargar reportes por rango de fechas (hasta 365 días)
///
/// El Patron solicita un reporte de ventas y gastos filtrado por un rango
/// de fechas específico. El rango máximo permitido es 365 días.
///
/// Validado por Requirement 12.3: Acceso a sección Reportes
class LoadReportsRequested extends PatronEvent {
  final String businessId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportsRequested({
    required this.businessId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [businessId, startDate, endDate];
}

/// Evento para cargar el equipo de Cajeros vinculados al negocio
///
/// El Patron solicita la lista de Cajeros vinculados con el estado de turno
/// de cada uno (activo o inactivo).
///
/// Validado por Requirement 12.4: Acceso a sección Equipo
class LoadTeamRequested extends PatronEvent {
  final String businessId;

  const LoadTeamRequested(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

/// Evento para cargar las notificaciones no leídas
///
/// El Patron solicita las alertas pendientes para mostrar el badge de
/// notificaciones en el Dashboard.
///
/// Validado por Requirement 12.5: Badge de notificaciones
class LoadNotificationsRequested extends PatronEvent {
  final String businessId;

  const LoadNotificationsRequested(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

/// Evento para cargar la información del negocio
///
/// El Patron solicita los datos del negocio incluyendo su plan de
/// suscripción para determinar la visibilidad de características especiales
/// como los módulos de IA.
///
/// Validado por Requirement 14.4: Mostrar módulos de IA solo para plan Business
class LoadBusinessInfoRequested extends PatronEvent {
  final String businessId;

  const LoadBusinessInfoRequested(this.businessId);

  @override
  List<Object?> get props => [businessId];
}
