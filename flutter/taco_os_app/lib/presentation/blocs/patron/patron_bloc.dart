import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';
import 'package:taco_os_app/domain/entities/notification.dart' as taco_os_app;
import 'package:taco_os_app/domain/entities/business.dart';
import 'patron_event.dart';
import 'patron_state.dart';

/// BLoC del Dashboard del Patron
///
/// Gestiona el estado del Dashboard del Patron, manejando la carga de:
/// - Ventas del día actual
/// - Reportes por rango de fechas
/// - Equipo de Cajeros vinculados
/// - Notificaciones no leídas
///
/// Por ahora accede directamente a la base de datos (DAOs) mientras se
/// implementan los use cases específicos del Patron.
///
/// Validado por Requirement 12.1: Dashboard del Patron
/// Validado por Requirement 12.2: Sección Ventas
/// Validado por Requirement 12.3: Sección Reportes
/// Validado por Requirement 12.4: Sección Equipo
/// Validado por Requirement 12.5: Badge de notificaciones
class PatronBloc extends Bloc<PatronEvent, PatronState> {
  final AppDatabase database;

  PatronBloc({required this.database}) : super(PatronInitial()) {
    on<LoadTodaySalesRequested>(_onLoadTodaySalesRequested);
    on<LoadReportsRequested>(_onLoadReportsRequested);
    on<LoadTeamRequested>(_onLoadTeamRequested);
    on<LoadNotificationsRequested>(_onLoadNotificationsRequested);
    on<LoadBusinessInfoRequested>(_onLoadBusinessInfoRequested);
  }

  /// Maneja la carga de ventas del día actual
  ///
  /// Consulta todas las ventas completadas del día actual para el negocio
  /// y calcula el total de ventas y desglose por método de pago.
  ///
  /// Validado por Requirement 12.2: Mostrar número de transacciones, total
  /// de ventas del día y desglose por método de pago
  Future<void> _onLoadTodaySalesRequested(
    LoadTodaySalesRequested event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());

    try {
      // Get start and end of today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Query all completed sales for today
      final allSales = await database.transactionDao.getPendingSales(
        event.businessId,
      );

      // Filter sales for today and completed status
      final todaySales = allSales.where((sale) {
        return sale.timestamp.isAfter(startOfDay) &&
            sale.timestamp.isBefore(endOfDay) &&
            sale.status == 'completed';
      }).toList();

      // Calculate totals
      final transactionCount = todaySales.length;
      final totalSales = todaySales.fold<double>(
        0.0,
        (sum, sale) => sum + sale.total,
      );

      final cashSales = todaySales
          .where((s) => s.paymentMethod == 'cash')
          .fold<double>(0.0, (sum, sale) => sum + sale.total);

      final cardSales = todaySales
          .where((s) => s.paymentMethod == 'card')
          .fold<double>(0.0, (sum, sale) => sum + sale.total);

      emit(
        TodaySalesLoaded(
          transactionCount: transactionCount,
          totalSales: totalSales,
          cashSales: cashSales,
          cardSales: cardSales,
        ),
      );
    } catch (e) {
      emit(PatronError('Error al cargar ventas del día: ${e.toString()}'));
    }
  }

  /// Maneja la carga de reportes por rango de fechas
  ///
  /// Consulta todas las ventas y gastos en el rango de fechas especificado
  /// (máximo 365 días) y calcula los totales.
  ///
  /// Validado por Requirement 12.3: Reporte de ventas y gastos filtrable
  /// por rango de fechas de hasta 365 días
  Future<void> _onLoadReportsRequested(
    LoadReportsRequested event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());

    try {
      // Validate date range (max 365 days)
      final daysDifference = event.endDate.difference(event.startDate).inDays;
      if (daysDifference > 365) {
        emit(const PatronError('El rango de fechas no puede superar 365 días'));
        return;
      }

      // Query all sales and expenses (we'll filter by date in memory)
      // In a production app, this should be done with a proper query
      final allSales = await database.transactionDao.getPendingSales(
        event.businessId,
      );
      final allExpenses = await database.transactionDao.getPendingExpenses(
        event.businessId,
      );

      // Filter by date range
      final salesInRange = allSales.where((sale) {
        return sale.timestamp.isAfter(event.startDate) &&
            sale.timestamp.isBefore(event.endDate) &&
            sale.status == 'completed';
      }).toList();

      final expensesInRange = allExpenses.where((expense) {
        return expense.timestamp.isAfter(event.startDate) &&
            expense.timestamp.isBefore(event.endDate);
      }).toList();

      // Calculate totals
      final totalSales = salesInRange.fold<double>(
        0.0,
        (sum, sale) => sum + sale.total,
      );

      final totalExpenses = expensesInRange.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      emit(
        ReportsLoaded(
          totalSales: totalSales,
          totalExpenses: totalExpenses,
          startDate: event.startDate,
          endDate: event.endDate,
          transactionCount: salesInRange.length,
        ),
      );
    } catch (e) {
      emit(PatronError('Error al cargar reportes: ${e.toString()}'));
    }
  }

  /// Maneja la carga del equipo de Cajeros vinculados al negocio
  ///
  /// Consulta todos los usuarios con rol 'cajero' vinculados al negocio
  /// y determina el estado de turno de cada uno (activo o inactivo).
  ///
  /// Validado por Requirement 12.4: Listar Cajeros vinculados al negocio
  /// con estado de turno (activo / inactivo)
  Future<void> _onLoadTeamRequested(
    LoadTeamRequested event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());

    try {
      // Query all users with role 'cajero' for this business
      final allUsers =
          await (database.select(database.users)
                ..where((u) => u.businessId.equals(event.businessId))
                ..where((u) => u.role.equals('cajero')))
              .get();

      // Get all active sessions to determine who has an active shift
      final activeSessions =
          await (database.select(database.cashSessions)
                ..where((s) => s.businessId.equals(event.businessId))
                ..where((s) => s.status.equals('open')))
              .get();

      // Map to active cashier IDs
      final activeCashierIds = activeSessions.map((s) => s.cashierId).toSet();

      // Build team member data
      final team = allUsers.map((user) {
        return TeamMemberData(
          id: user.id,
          name: user.name,
          email: user.email,
          hasActiveShift: activeCashierIds.contains(user.id),
        );
      }).toList();

      emit(TeamLoaded(team));
    } catch (e) {
      emit(PatronError('Error al cargar equipo: ${e.toString()}'));
    }
  }

  /// Maneja la carga de notificaciones no leídas
  ///
  /// Consulta todas las notificaciones con isRead = false para mostrar
  /// el badge de notificaciones en el Dashboard.
  ///
  /// Validado por Requirement 12.5: Badge de notificaciones con número
  /// de alertas pendientes no leídas
  Future<void> _onLoadNotificationsRequested(
    LoadNotificationsRequested event,
    Emitter<PatronState> emit,
  ) async {
    emit(PatronLoading());

    try {
      // Query unread notifications
      final notificationsData =
          await (database.select(database.notifications)
                ..where((n) => n.businessId.equals(event.businessId))
                ..where((n) => n.isRead.equals(false))
                ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
              .get();

      // Convert to domain entities
      final notifications = notificationsData.map((data) {
        return taco_os_app.Notification(
          id: data.id,
          businessId: data.businessId,
          type: _parseNotificationType(data.type),
          message: data.message,
          isRead: data.isRead,
          createdAt: data.createdAt,
        );
      }).toList();

      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(PatronError('Error al cargar notificaciones: ${e.toString()}'));
    }
  }

  /// Parse notification type from string
  taco_os_app.NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'cancellation':
        return taco_os_app.NotificationType.cancellation;
      case 'surplus':
        return taco_os_app.NotificationType.surplus;
      case 'shortage':
        return taco_os_app.NotificationType.shortage;
      case 'auto_close':
        return taco_os_app.NotificationType.autoClose;
      default:
        return taco_os_app.NotificationType.cancellation;
    }
  }

  /// Maneja la carga de información del negocio
  ///
  /// Consulta los datos del negocio incluyendo su plan de suscripción
  /// para determinar qué características están disponibles (especialmente
  /// los módulos de IA que solo están disponibles para el plan Business).
  ///
  /// Validado por Requirement 14.4: Módulos de IA solo para plan Business
  Future<void> _onLoadBusinessInfoRequested(
    LoadBusinessInfoRequested event,
    Emitter<PatronState> emit,
  ) async {
    try {
      // Query business data from database
      final businessData = await (database.select(
        database.businesses,
      )..where((b) => b.id.equals(event.businessId))).getSingleOrNull();

      if (businessData == null) {
        emit(const PatronError('No se encontró la información del negocio'));
        return;
      }

      // Convert to domain entity
      final business = Business(
        id: businessData.id,
        name: businessData.name,
        ownerId: businessData.ownerId,
        subscriptionPlan: _parseSubscriptionPlan(businessData.plan),
        createdAt: businessData.createdAt,
      );

      emit(BusinessInfoLoaded(business));
    } catch (e) {
      emit(
        PatronError('Error al cargar información del negocio: ${e.toString()}'),
      );
    }
  }

  /// Parse subscription plan from string
  SubscriptionPlan _parseSubscriptionPlan(String plan) {
    switch (plan) {
      case 'free':
        return SubscriptionPlan.free;
      case 'premium':
        return SubscriptionPlan.premium;
      case 'business':
        return SubscriptionPlan.business;
      default:
        return SubscriptionPlan.free;
    }
  }
}
