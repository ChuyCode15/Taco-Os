import 'package:drift/drift.dart';
import 'businesses.dart';

@DataClassName('ProductData')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get category => text()(); // 'comida' | 'bebidas' | 'postres'
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
