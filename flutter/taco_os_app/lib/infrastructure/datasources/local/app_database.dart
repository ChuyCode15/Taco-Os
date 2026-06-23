import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/users.dart';
import 'tables/businesses.dart';
import 'tables/products.dart';
import 'tables/cash_sessions.dart';
import 'tables/sales.dart';
import 'tables/sale_items.dart';
import 'tables/expenses.dart';
import 'tables/cortes.dart';
import 'tables/notifications.dart';
import 'daos/transaction_dao.dart';
import 'daos/product_dao.dart';
import 'daos/session_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Businesses,
    Products,
    CashSessions,
    Sales,
    SaleItems,
    Expenses,
    Cortes,
    Notifications,
  ],
  daos: [TransactionDao, ProductDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Testing constructor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'taco_os_db');
  }
}
