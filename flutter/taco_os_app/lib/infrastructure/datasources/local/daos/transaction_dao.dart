import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sales.dart';
import '../tables/sale_items.dart';
import '../tables/expenses.dart';
import '../tables/cortes.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Sales, SaleItems, Expenses, Cortes])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // ===== SALES QUERIES =====

  /// Get all sales for a specific business and session
  /// MULTI-TENANT: Filters by business_id
  Future<List<SaleData>> getSalesByBusinessAndSession(
    String businessId,
    String sessionId,
  ) {
    return (select(sales)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.sessionId.equals(sessionId))
          ..orderBy([(s) => OrderingTerm.desc(s.timestamp)]))
        .get();
  }

  /// Get all completed (non-cancelled) sales for a session
  /// MULTI-TENANT: Filters by business_id
  Future<List<SaleData>> getCompletedSalesBySession(
    String businessId,
    String sessionId,
  ) {
    return (select(sales)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.sessionId.equals(sessionId))
          ..where((s) => s.status.equals('completed'))
          ..orderBy([(s) => OrderingTerm.desc(s.timestamp)]))
        .get();
  }

  /// Get pending (unsynced) sales for a business
  /// MULTI-TENANT: Filters by business_id
  Future<List<SaleData>> getPendingSales(String businessId) {
    return (select(sales)
          ..where((s) => s.businessId.equals(businessId))
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)]))
        .get();
  }

  /// Get sale items for a specific sale
  Future<List<SaleItemData>> getSaleItems(String saleId) {
    return (select(saleItems)..where((si) => si.saleId.equals(saleId))).get();
  }

  /// Insert a new sale
  Future<int> insertSale(SalesCompanion sale) {
    return into(sales).insert(sale);
  }

  /// Insert multiple sale items
  Future<void> insertSaleItems(List<SaleItemsCompanion> items) {
    return batch((batch) {
      batch.insertAll(saleItems, items);
    });
  }

  /// Update sale status (for cancellation)
  Future<bool> updateSale(String saleId, SalesCompanion updates) {
    return (update(sales)..where((s) => s.id.equals(saleId)))
        .write(updates)
        .then((count) => count > 0);
  }

  /// Mark sale as synced
  Future<bool> markSaleSynced(String saleId) {
    return (update(sales)..where((s) => s.id.equals(saleId)))
        .write(
          SalesCompanion(
            isSynced: const Value(true),
            syncError: const Value(null),
          ),
        )
        .then((count) => count > 0);
  }

  /// Mark sale with sync error
  Future<bool> markSaleSyncError(String saleId, String error) {
    return (update(sales)..where((s) => s.id.equals(saleId)))
        .write(SalesCompanion(syncError: Value(error)))
        .then((count) => count > 0);
  }

  // ===== EXPENSES QUERIES =====

  /// Get all expenses for a specific business and session
  /// MULTI-TENANT: Filters by business_id
  Future<List<ExpenseData>> getExpensesByBusinessAndSession(
    String businessId,
    String sessionId,
  ) {
    return (select(expenses)
          ..where((e) => e.businessId.equals(businessId))
          ..where((e) => e.sessionId.equals(sessionId))
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)]))
        .get();
  }

  /// Get pending (unsynced) expenses for a business
  /// MULTI-TENANT: Filters by business_id
  Future<List<ExpenseData>> getPendingExpenses(String businessId) {
    return (select(expenses)
          ..where((e) => e.businessId.equals(businessId))
          ..where((e) => e.isSynced.equals(false))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .get();
  }

  /// Insert a new expense
  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  /// Mark expense as synced
  Future<bool> markExpenseSynced(String expenseId) {
    return (update(expenses)..where((e) => e.id.equals(expenseId)))
        .write(
          ExpensesCompanion(
            isSynced: const Value(true),
            syncError: const Value(null),
          ),
        )
        .then((count) => count > 0);
  }

  /// Mark expense with sync error
  Future<bool> markExpenseSyncError(String expenseId, String error) {
    return (update(expenses)..where((e) => e.id.equals(expenseId)))
        .write(ExpensesCompanion(syncError: Value(error)))
        .then((count) => count > 0);
  }

  // ===== CORTES QUERIES =====

  /// Get all cortes for a specific business
  /// MULTI-TENANT: Filters by business_id
  Future<List<CorteData>> getCortesByBusiness(String businessId) {
    return (select(cortes)
          ..where((c) => c.businessId.equals(businessId))
          ..orderBy([(c) => OrderingTerm.desc(c.closedAt)]))
        .get();
  }

  /// Get corte for a specific session
  /// MULTI-TENANT: Filters by business_id
  Future<CorteData?> getCorteBySession(String businessId, String sessionId) {
    return (select(cortes)
          ..where((c) => c.businessId.equals(businessId))
          ..where((c) => c.sessionId.equals(sessionId)))
        .getSingleOrNull();
  }

  /// Get pending (unsynced) cortes for a business
  /// MULTI-TENANT: Filters by business_id
  Future<List<CorteData>> getPendingCortes(String businessId) {
    return (select(cortes)
          ..where((c) => c.businessId.equals(businessId))
          ..where((c) => c.isSynced.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.closedAt)]))
        .get();
  }

  /// Insert a new corte
  Future<int> insertCorte(CortesCompanion corte) {
    return into(cortes).insert(corte);
  }

  /// Mark corte as synced
  Future<bool> markCorteSynced(String corteId) {
    return (update(cortes)..where((c) => c.id.equals(corteId)))
        .write(
          CortesCompanion(
            isSynced: const Value(true),
            syncError: const Value(null),
          ),
        )
        .then((count) => count > 0);
  }

  /// Mark corte with sync error
  Future<bool> markCorteSyncError(String corteId, String error) {
    return (update(cortes)..where((c) => c.id.equals(corteId)))
        .write(CortesCompanion(syncError: Value(error)))
        .then((count) => count > 0);
  }
}
