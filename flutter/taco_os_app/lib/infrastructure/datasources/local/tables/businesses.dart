import 'package:drift/drift.dart';

@DataClassName('BusinessData')
class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // max 60 chars
  TextColumn get ownerId => text()();
  TextColumn get plan => text()(); // 'free' | 'premium' | 'business'
  TextColumn get qrCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
