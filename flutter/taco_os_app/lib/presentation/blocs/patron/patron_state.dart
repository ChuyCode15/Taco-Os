import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/notification.dart';
import 'package:taco_os_app/domain/entities/business.dart';

/// Estados del PatronBloc
///
/// Representa los diferentes estados del Dashboard del Patron durante
/// la carga de datos: ventas del día, reportes, equipo y notificaciones.
///
/// Validado por Requirement 12.1: Dashboard del Patron
/// Validado por Requirement 12.2: Sección Ventas
/// Validado por Requirement 12.3: Sección Reportes
/// Validado por Requirement 12.4: Sección Equipo
/// Validado por Requirement 12.5: Badge de notificaciones
abstract class PatronState extends Equatable {
  const PatronState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del Dashboard del Patron
///
/// El Dashboard no ha cargado ningún dato todavía.
class PatronInitial extends PatronState {}

/// Estado de carga de datos del Dashboard
///
/// El Patron está esperando la respuesta de una consulta (ventas, reportes,
/// equipo o notificaciones).
class PatronLoading extends PatronState {}

/// Estado con datos de ventas del día cargados
///
/// Contiene el número de transacciones, total de ventas y desglose por
/// método de pago (efectivo y tarjeta).
///
/// Validado por Requirement 12.2: Mostrar ventas del día con desglose
class TodaySalesLoaded extends PatronState {
  final int transactionCount;
  final double totalSales;
  final double cashSales;
  final double cardSales;

  const TodaySalesLoaded({
    required this.transactionCount,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
  });

  @override
  List<Object?> get props => [
    transactionCount,
    totalSales,
    cashSales,
    cardSales,
  ];
}

/// Estado con datos de reportes cargados
///
/// Contiene las ventas y gastos totales del rango de fechas consultado,
/// junto con el rango de fechas para mostrar en caso de estado vacío.
///
/// Validado por Requirement 12.3: Reporte filtrable por rango de fechas
class ReportsLoaded extends PatronState {
  final double totalSales;
  final double totalExpenses;
  final DateTime startDate;
  final DateTime endDate;
  final int transactionCount;

  const ReportsLoaded({
    required this.totalSales,
    required this.totalExpenses,
    required this.startDate,
    required this.endDate,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
    totalSales,
    totalExpenses,
    startDate,
    endDate,
    transactionCount,
  ];
}

/// Estado con datos del equipo de Cajeros cargados
///
/// Contiene la lista de Cajeros vinculados al negocio con el estado de turno
/// de cada uno (activo o inactivo).
///
/// Validado por Requirement 12.4: Listar Cajeros con estado de turno
class TeamLoaded extends PatronState {
  final List<TeamMemberData> team;

  const TeamLoaded(this.team);

  @override
  List<Object?> get props => [team];
}

/// Datos de un miembro del equipo (Cajero)
///
/// Contiene el nombre del Cajero y el estado de su turno.
class TeamMemberData extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool hasActiveShift;

  const TeamMemberData({
    required this.id,
    required this.name,
    required this.email,
    required this.hasActiveShift,
  });

  @override
  List<Object?> get props => [id, name, email, hasActiveShift];
}

/// Estado con notificaciones no leídas cargadas
///
/// Contiene la lista de notificaciones pendientes para mostrar el badge
/// en el Dashboard del Patron. Si hay más de 99, muestra "99+".
///
/// Validado por Requirement 12.5: Badge de notificaciones con conteo
class NotificationsLoaded extends PatronState {
  final List<Notification> notifications;

  const NotificationsLoaded(this.notifications);

  int get unreadCount => notifications.length;

  String get badgeText {
    if (unreadCount == 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  @override
  List<Object?> get props => [notifications];
}

/// Estado de error en el Dashboard del Patron
///
/// Se emite cuando falla la carga de ventas, reportes, equipo o notificaciones.
class PatronError extends PatronState {
  final String message;

  const PatronError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado con información del negocio cargada
///
/// Contiene los datos del negocio incluyendo su plan de suscripción,
/// utilizado para determinar qué características están disponibles
/// (especialmente los módulos de IA para el plan Business).
///
/// Validado por Requirement 14.4: Módulos de IA disponibles solo para plan Business
class BusinessInfoLoaded extends PatronState {
  final Business business;

  const BusinessInfoLoaded(this.business);

  /// Indica si el negocio tiene acceso a módulos de IA
  bool get hasAiModules => business.hasAiModules;

  @override
  List<Object?> get props => [business];
}
