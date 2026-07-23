import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/cash_sessions.dart';
import '../tables/sales.dart';
import '../tables/expenses.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [CashSessions, Sales, Expenses])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  // ===== CASH SESSION QUERIES =====

  /// Get active (open) session for a business
  /// MULTI-TENANT: Filters by business_id
  Future<CashSessionData?> getActiveSession(String businessId) {
    return (select(cashSessions)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.status.equals('open'))
          ..orderBy([(s) => OrderingTerm.desc(s.openedAt)]))
        .getSingleOrNull();
  }

  /// Get session by ID and business
  /// MULTI-TENANT: Filters by business_id
  Future<CashSessionData?> getSessionById(String businessId, String sessionId) {
    return (select(cashSessions)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
  }

  /// Get all sessions for a business (for history)
  /// MULTI-TENANT: Filters by business_id
  Future<List<CashSessionData>> getSessionsByBusiness(String businessId) {
    return (select(cashSessions)
          ..where((s) => s.businessId.equals(businessId))
          ..orderBy([(s) => OrderingTerm.desc(s.openedAt)]))
        .get();
  }

  /// Get pending (unsynced) sessions for a business
  /// MULTI-TENANT: Filters by business_id
  Future<List<CashSessionData>> getPendingSessions(String businessId) {
    return (select(cashSessions)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.openedAt)]))
        .get();
  }

  /// Insert a new cash session
  Future<int> insertSession(CashSessionsCompanion session) {
    return into(cashSessions).insert(session);
  }

  /// Update session (for closing)
  Future<bool> updateSession(String sessionId, CashSessionsCompanion updates) {
    return (update(cashSessions)..where((s) => s.id.equals(sessionId)))
        .write(updates)
        .then((count) => count > 0);
  }

  /// Close a session
  Future<bool> closeSession(String sessionId, DateTime closedAt) {
    return (update(cashSessions)..where((s) => s.id.equals(sessionId)))
        .write(
          CashSessionsCompanion(
            status: const Value('closed'),
            closedAt: Value(closedAt),
          ),
        )
        .then((count) => count > 0);
  }

  /// Mark session as synced
  Future<bool> markSessionSynced(String sessionId) {
    return (update(cashSessions)..where((s) => s.id.equals(sessionId)))
        .write(
          CashSessionsCompanion(
            isSynced: const Value(true),
            syncError: const Value(null),
          ),
        )
        .then((count) => count > 0);
  }

  /// Mark session with sync error
  Future<bool> markSessionSyncError(String sessionId, String error) {
    return (update(cashSessions)..where((s) => s.id.equals(sessionId)))
        .write(CashSessionsCompanion(syncError: Value(error)))
        .then((count) => count > 0);
  }

  // ===== SHIFT SUMMARY QUERIES =====

  /// Get shift summary for a specific session
  /// Calculates totals from sales and expenses
  /// MULTI-TENANT: Filters by business_id
  Future<ShiftSummary> getShiftSummary(
    String businessId,
    String sessionId,
  ) async {
    // Get all completed sales for this session
    final salesList =
        await (select(sales)
              ..where((s) => s.businessId.equals(businessId))
              ..where((s) => s.sessionId.equals(sessionId))
              ..where((s) => s.status.equals('completed')))
            .get();

    // Get all expenses for this session
    final expensesList =
        await (select(expenses)
              ..where((e) => e.businessId.equals(businessId))
              ..where((e) => e.sessionId.equals(sessionId)))
            .get();

    // Calculate totals
    final totalSales = salesList.fold<double>(
      0.0,
      (sum, sale) => sum + sale.total,
    );

    final totalCash = salesList
        .where((s) => s.paymentMethod == 'cash')
        .fold<double>(0.0, (sum, sale) => sum + sale.total);

    final totalCard = salesList
        .where((s) => s.paymentMethod == 'card')
        .fold<double>(0.0, (sum, sale) => sum + sale.total);

    final totalExpenses = expensesList.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Get session to get opening balance
    final session = await getSessionById(businessId, sessionId);
    final openingBalance = session?.openingBalance ?? 0.0;

    final expectedCash = openingBalance + totalCash - totalExpenses;

    return ShiftSummary(
      transactionCount: salesList.length,
      totalSales: totalSales,
      totalCash: totalCash,
      totalCard: totalCard,
      totalExpenses: totalExpenses,
      expectedCash: expectedCash,
    );
  }

  /// Check if a business has any active session
  /// MULTI-TENANT: Filters by business_id
  Future<bool> hasActiveSession(String businessId) async {
    final session = await getActiveSession(businessId);
    return session != null;
  }
}

/// Data class for shift summary (¿Cómo voy?)
class ShiftSummary {
  final int transactionCount;
  final double totalSales;
  final double totalCash;
  final double totalCard;
  final double totalExpenses;
  final double expectedCash;

  ShiftSummary({
    required this.transactionCount,
    required this.totalSales,
    required this.totalCash,
    required this.totalCard,
    required this.totalExpenses,
    required this.expectedCash,
  });
}
