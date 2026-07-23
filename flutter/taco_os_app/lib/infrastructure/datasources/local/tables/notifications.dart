import 'package:drift/drift.dart';
import 'businesses.dart';

@DataClassName('NotificationData')
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get type =>
      text()(); // 'cancellation' | 'surplus' | 'shortage' | 'auto_close'
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
