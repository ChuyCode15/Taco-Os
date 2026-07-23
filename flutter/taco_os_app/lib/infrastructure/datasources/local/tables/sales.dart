import 'package:drift/drift.dart';
import 'cash_sessions.dart';
import 'businesses.dart';

@DataClassName('SaleData')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(CashSessions, #id)();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get cashierId => text()();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text()(); // 'cash' | 'card'
  TextColumn get cardPhotoUrl => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('completed'),
  )(); // 'completed' | 'cancelled'
  TextColumn get cancellationPhotoUrl => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
