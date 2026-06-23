// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CashSessionsTable get cashSessions => attachedDatabase.cashSessions;
  $SalesTable get sales => attachedDatabase.sales;
  $SaleItemsTable get saleItems => attachedDatabase.saleItems;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $CortesTable get cortes => attachedDatabase.cortes;
  TransactionDaoManager get managers => TransactionDaoManager(this);
}

class TransactionDaoManager {
  final _$TransactionDaoMixin _db;
  TransactionDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CashSessionsTableTableManager get cashSessions =>
      $$CashSessionsTableTableManager(_db.attachedDatabase, _db.cashSessions);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db.attachedDatabase, _db.saleItems);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$CortesTableTableManager get cortes =>
      $$CortesTableTableManager(_db.attachedDatabase, _db.cortes);
}
