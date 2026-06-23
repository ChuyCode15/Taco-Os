import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase', () {
    test('should initialize database successfully', () async {
      // Verify database is initialized
      expect(database, isA<AppDatabase>());
      expect(database.schemaVersion, 1);
    });

    test('should create all tables', () async {
      // This implicitly tests that all tables are created during initialization
      // by the drift migration system
      final result = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
          .get();

      final tableNames = result
          .map((row) => row.data['name'] as String)
          .toList();

      expect(tableNames, contains('users'));
      expect(tableNames, contains('businesses'));
      expect(tableNames, contains('products'));
      expect(tableNames, contains('cash_sessions'));
      expect(tableNames, contains('sales'));
      expect(tableNames, contains('sale_items'));
      expect(tableNames, contains('expenses'));
      expect(tableNames, contains('cortes'));
      expect(tableNames, contains('notifications'));
    });

    test('should enforce multi-tenant isolation in TransactionDao', () async {
      const businessId1 = 'business-1';
      const businessId2 = 'business-2';

      // Insert businesses first
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId1,
              name: 'Test Business 1',
              ownerId: 'owner-1',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId2,
              name: 'Test Business 2',
              ownerId: 'owner-2',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      // Insert cash sessions
      await database
          .into(database.cashSessions)
          .insert(
            CashSessionsCompanion.insert(
              id: 'session-1',
              businessId: businessId1,
              cashierId: 'cashier-1',
              deviceId: 'device-1',
              openedAt: DateTime.now(),
            ),
          );
      await database
          .into(database.cashSessions)
          .insert(
            CashSessionsCompanion.insert(
              id: 'session-2',
              businessId: businessId2,
              cashierId: 'cashier-2',
              deviceId: 'device-2',
              openedAt: DateTime.now(),
            ),
          );

      // Insert sales for different businesses
      await database.transactionDao.insertSale(
        SalesCompanion.insert(
          id: 'sale-1',
          sessionId: 'session-1',
          businessId: businessId1,
          cashierId: 'cashier-1',
          total: 100.0,
          paymentMethod: 'cash',
          timestamp: DateTime.now(),
        ),
      );
      await database.transactionDao.insertSale(
        SalesCompanion.insert(
          id: 'sale-2',
          sessionId: 'session-2',
          businessId: businessId2,
          cashierId: 'cashier-2',
          total: 200.0,
          paymentMethod: 'card',
          timestamp: DateTime.now(),
        ),
      );

      // Verify business1 only sees its own sales
      final business1Sales = await database.transactionDao
          .getSalesByBusinessAndSession(businessId1, 'session-1');
      expect(business1Sales.length, 1);
      expect(business1Sales.first.id, 'sale-1');
      expect(business1Sales.first.total, 100.0);

      // Verify business2 only sees its own sales
      final business2Sales = await database.transactionDao
          .getSalesByBusinessAndSession(businessId2, 'session-2');
      expect(business2Sales.length, 1);
      expect(business2Sales.first.id, 'sale-2');
      expect(business2Sales.first.total, 200.0);
    });

    test('should enforce multi-tenant isolation in ProductDao', () async {
      const businessId1 = 'business-1';
      const businessId2 = 'business-2';

      // Insert businesses
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId1,
              name: 'Test Business 1',
              ownerId: 'owner-1',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId2,
              name: 'Test Business 2',
              ownerId: 'owner-2',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      // Insert products for different businesses
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-1',
          businessId: businessId1,
          name: 'Taco',
          price: 10.0,
          category: 'comida',
          updatedAt: DateTime.now(),
        ),
      );
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-2',
          businessId: businessId2,
          name: 'Burrito',
          price: 15.0,
          category: 'comida',
          updatedAt: DateTime.now(),
        ),
      );

      // Verify business1 only sees its own products
      final business1Products = await database.productDao
          .getAllProductsByBusiness(businessId1);
      expect(business1Products.length, 1);
      expect(business1Products.first.name, 'Taco');

      // Verify business2 only sees its own products
      final business2Products = await database.productDao
          .getAllProductsByBusiness(businessId2);
      expect(business2Products.length, 1);
      expect(business2Products.first.name, 'Burrito');
    });

    test('should filter products by category', () async {
      const businessId = 'business-1';

      // Insert business
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId,
              name: 'Test Business',
              ownerId: 'owner-1',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      // Insert products in different categories
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-1',
          businessId: businessId,
          name: 'Taco',
          price: 10.0,
          category: 'comida',
          updatedAt: DateTime.now(),
        ),
      );
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-2',
          businessId: businessId,
          name: 'Refresco',
          price: 5.0,
          category: 'bebidas',
          updatedAt: DateTime.now(),
        ),
      );
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-3',
          businessId: businessId,
          name: 'Flan',
          price: 8.0,
          category: 'postres',
          updatedAt: DateTime.now(),
        ),
      );

      // Get products by category
      final comidaProducts = await database.productDao
          .getProductsByBusinessAndCategory(businessId, 'comida');
      expect(comidaProducts.length, 1);
      expect(comidaProducts.first.name, 'Taco');

      final bebidasProducts = await database.productDao
          .getProductsByBusinessAndCategory(businessId, 'bebidas');
      expect(bebidasProducts.length, 1);
      expect(bebidasProducts.first.name, 'Refresco');

      final postresProducts = await database.productDao
          .getProductsByBusinessAndCategory(businessId, 'postres');
      expect(postresProducts.length, 1);
      expect(postresProducts.first.name, 'Flan');
    });

    test('should calculate shift summary correctly', () async {
      const businessId = 'business-1';
      const sessionId = 'session-1';
      const openingBalance = 100.0;

      // Insert business
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: businessId,
              name: 'Test Business',
              ownerId: 'owner-1',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      // Insert session
      await database.sessionDao.insertSession(
        CashSessionsCompanion.insert(
          id: sessionId,
          businessId: businessId,
          cashierId: 'cashier-1',
          deviceId: 'device-1',
          openingBalance: const Value(openingBalance),
          openedAt: DateTime.now(),
        ),
      );

      // Insert sales
      await database.transactionDao.insertSale(
        SalesCompanion.insert(
          id: 'sale-1',
          sessionId: sessionId,
          businessId: businessId,
          cashierId: 'cashier-1',
          total: 50.0,
          paymentMethod: 'cash',
          timestamp: DateTime.now(),
        ),
      );
      await database.transactionDao.insertSale(
        SalesCompanion.insert(
          id: 'sale-2',
          sessionId: sessionId,
          businessId: businessId,
          cashierId: 'cashier-1',
          total: 30.0,
          paymentMethod: 'card',
          timestamp: DateTime.now(),
        ),
      );

      // Insert expense
      await database.transactionDao.insertExpense(
        ExpensesCompanion.insert(
          id: 'expense-1',
          sessionId: sessionId,
          businessId: businessId,
          cashierId: 'cashier-1',
          description: 'Hielo',
          amount: 10.0,
          timestamp: DateTime.now(),
        ),
      );

      // Get shift summary
      final summary = await database.sessionDao.getShiftSummary(
        businessId,
        sessionId,
      );

      expect(summary.transactionCount, 2);
      expect(summary.totalSales, 80.0);
      expect(summary.totalCash, 50.0);
      expect(summary.totalCard, 30.0);
      expect(summary.totalExpenses, 10.0);
      // expectedCash = openingBalance + totalCash - totalExpenses
      // expectedCash = 100.0 + 50.0 - 10.0 = 140.0
      expect(summary.expectedCash, 140.0);
    });
  });
}
