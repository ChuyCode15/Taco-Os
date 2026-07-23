// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CashSessionsTable get cashSessions => attachedDatabase.cashSessions;
  $SalesTable get sales => attachedDatabase.sales;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CashSessionsTableTableManager get cashSessions =>
      $$CashSessionsTableTableManager(_db.attachedDatabase, _db.cashSessions);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
