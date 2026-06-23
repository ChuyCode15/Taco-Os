import 'package:drift/drift.dart';
import 'cash_sessions.dart';
import 'businesses.dart';

@DataClassName('ExpenseData')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(CashSessions, #id)();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get cashierId => text()();
  TextColumn get description => text()(); // max 100 chars
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
