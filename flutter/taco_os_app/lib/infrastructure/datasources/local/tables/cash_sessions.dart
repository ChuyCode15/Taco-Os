import 'package:drift/drift.dart';
import 'businesses.dart';

@DataClassName('CashSessionData')
class CashSessions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get cashierId => text()();
  TextColumn get deviceId => text()();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // 'open' | 'closed'
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
