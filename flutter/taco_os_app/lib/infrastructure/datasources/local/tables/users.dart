import 'package:drift/drift.dart';

@DataClassName('UserData')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // 'cajero' | 'patron'
  TextColumn get businessId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
