import 'package:drift/drift.dart';
import 'cash_sessions.dart';
import 'businesses.dart';

@DataClassName('CorteData')
class Cortes extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(CashSessions, #id)();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get cashierId => text()();
  RealColumn get totalCashSales => real()();
  RealColumn get totalCardSales => real()();
  RealColumn get totalExpenses => real()();
  RealColumn get openingBalance => real()();
  RealColumn get countedCash => real()(); // 0.00–999,999.99
  RealColumn get difference => real()(); // sobrante (+) / faltante (-)
  DateTimeColumn get closedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
