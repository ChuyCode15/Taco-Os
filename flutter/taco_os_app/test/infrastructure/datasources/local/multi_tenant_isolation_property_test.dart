import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';

/// **Property 5: Multi-Tenant Isolation**
/// **Validates: Requirements 15.1, 15.2**
///
/// This property test verifies that no query returns records with a different
/// business_id than the active session's business_id. The test:
/// 1. Inserts test data for multiple business_id values
/// 2. Generates arbitrary pairs (business_id_A, business_id_B) where A ≠ B
/// 3. Queries using business_id_A and verifies no results contain business_id_B
void main() {
  late AppDatabase database;
  final random = Random(42); // Fixed seed for reproducibility

  setUp(() {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Property-Based Test: Multi-Tenant Isolation (Property 5)', () {
    test(
      'Property: Queries for business A never return records from business B',
      () async {
        const numBusinesses = 5; // Test with 5 different businesses
        const numTestCases = 50; // Number of query pairs to test

        // Generate business IDs
        final businessIds = List.generate(
          numBusinesses,
          (i) => 'business-${i + 1}',
        );

        // Setup: Create test data for all businesses
        await _setupMultiTenantData(database, businessIds);

        // Property test: For each pair of distinct business IDs,
        // verify that queries for business A never return data from business B
        for (int testCase = 0; testCase < numTestCases; testCase++) {
          // Generate two distinct random business IDs
          final businessA = businessIds[random.nextInt(numBusinesses)];
          String businessB;
          do {
            businessB = businessIds[random.nextInt(numBusinesses)];
          } while (businessA == businessB); // Ensure A ≠ B

          // Test ProductDao queries
          await _verifyProductIsolation(
            database,
            businessA,
            businessB,
            testCase,
          );

          // Test TransactionDao queries (sales)
          await _verifySalesIsolation(database, businessA, businessB, testCase);

          // Test TransactionDao queries (expenses)
          await _verifyExpensesIsolation(
            database,
            businessA,
            businessB,
            testCase,
          );

          // Test SessionDao queries
          await _verifySessionIsolation(
            database,
            businessA,
            businessB,
            testCase,
          );

          // Test cortes isolation
          await _verifyCortesIsolation(
            database,
            businessA,
            businessB,
            testCase,
          );
        }
      },
    );

    test(
      'Property: Shift summary only includes transactions from the queried business',
      () async {
        const numBusinesses = 3;
        const numTestCases = 20;

        final businessIds = List.generate(
          numBusinesses,
          (i) => 'business-summary-${i + 1}',
        );

        await _setupMultiTenantData(database, businessIds);

        for (int testCase = 0; testCase < numTestCases; testCase++) {
          final businessA = businessIds[random.nextInt(numBusinesses)];
          String businessB;
          do {
            businessB = businessIds[random.nextInt(numBusinesses)];
          } while (businessA == businessB);

          // Get active session for business A
          final sessionA = await database.sessionDao.getActiveSession(
            businessA,
          );
          expect(
            sessionA != null,
            true,
            reason: 'Business $businessA should have an active session',
          );

          // Get shift summary for business A
          final summaryA = await database.sessionDao.getShiftSummary(
            businessA,
            sessionA!.id,
          );

          // Get all sales for business A's session
          final salesA = await database.transactionDao
              .getSalesByBusinessAndSession(businessA, sessionA.id);

          // Verify all sales in the summary belong to business A
          for (final sale in salesA) {
            expect(
              sale.businessId,
              businessA,
              reason:
                  'Test case $testCase: Sale ${sale.id} in business $businessA summary should not belong to business $businessB',
            );
            expect(
              sale.businessId,
              isNot(businessB),
              reason:
                  'Test case $testCase: Sale ${sale.id} should not belong to business $businessB',
            );
          }

          // Get all expenses for business A's session
          final expensesA = await database.transactionDao
              .getExpensesByBusinessAndSession(businessA, sessionA.id);

          // Verify all expenses in the summary belong to business A
          for (final expense in expensesA) {
            expect(
              expense.businessId,
              businessA,
              reason:
                  'Test case $testCase: Expense ${expense.id} in business $businessA summary should not belong to business $businessB',
            );
            expect(
              expense.businessId,
              isNot(businessB),
              reason:
                  'Test case $testCase: Expense ${expense.id} should not belong to business $businessB',
            );
          }

          // Verify the summary calculation is correct for business A only
          final expectedTotal = salesA
              .where((s) => s.status == 'completed')
              .fold<double>(0.0, (sum, sale) => sum + sale.total);
          expect(
            summaryA.totalSales,
            expectedTotal,
            reason:
                'Test case $testCase: Total sales should match for business $businessA',
          );
        }
      },
    );

    test('Property: Pending sync queries never leak data across businesses', () async {
      const numBusinesses = 4;
      const numTestCases = 30;

      final businessIds = List.generate(
        numBusinesses,
        (i) => 'business-sync-${i + 1}',
      );

      await _setupMultiTenantData(database, businessIds);

      for (int testCase = 0; testCase < numTestCases; testCase++) {
        final businessA = businessIds[random.nextInt(numBusinesses)];
        String businessB;
        do {
          businessB = businessIds[random.nextInt(numBusinesses)];
        } while (businessA == businessB);

        // Get pending sales for business A
        final pendingSalesA = await database.transactionDao.getPendingSales(
          businessA,
        );

        for (final sale in pendingSalesA) {
          expect(
            sale.businessId,
            businessA,
            reason:
                'Test case $testCase: Pending sale ${sale.id} should belong to business $businessA',
          );
          expect(
            sale.businessId,
            isNot(businessB),
            reason:
                'Test case $testCase: Pending sale should not leak to business $businessB',
          );
        }

        // Get pending expenses for business A
        final pendingExpensesA = await database.transactionDao
            .getPendingExpenses(businessA);

        for (final expense in pendingExpensesA) {
          expect(
            expense.businessId,
            businessA,
            reason:
                'Test case $testCase: Pending expense ${expense.id} should belong to business $businessA',
          );
          expect(
            expense.businessId,
            isNot(businessB),
            reason:
                'Test case $testCase: Pending expense should not leak to business $businessB',
          );
        }

        // Get pending sessions for business A
        final pendingSessionsA = await database.sessionDao.getPendingSessions(
          businessA,
        );

        for (final session in pendingSessionsA) {
          expect(
            session.businessId,
            businessA,
            reason:
                'Test case $testCase: Pending session ${session.id} should belong to business $businessA',
          );
          expect(
            session.businessId,
            isNot(businessB),
            reason:
                'Test case $testCase: Pending session should not leak to business $businessB',
          );
        }
      }
    });
  });
}

/// Setup multi-tenant test data for all businesses
Future<void> _setupMultiTenantData(
  AppDatabase database,
  List<String> businessIds,
) async {
  for (int i = 0; i < businessIds.length; i++) {
    final businessId = businessIds[i];
    final sessionId = 'session-$businessId';
    final cashierId = 'cashier-$businessId';

    // Insert business
    await database
        .into(database.businesses)
        .insert(
          BusinessesCompanion.insert(
            id: businessId,
            name: 'Business ${i + 1}',
            ownerId: 'owner-$businessId',
            plan: 'free',
            createdAt: DateTime.now(),
          ),
        );

    // Insert cash session
    await database.sessionDao.insertSession(
      CashSessionsCompanion.insert(
        id: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        deviceId: 'device-$businessId',
        openingBalance: Value(100.0 + i * 50.0),
        openedAt: DateTime.now().subtract(Duration(hours: i)),
      ),
    );

    // Insert products for each category
    final categories = ['comida', 'bebidas', 'postres'];
    for (int j = 0; j < categories.length; j++) {
      await database.productDao.insertProduct(
        ProductsCompanion.insert(
          id: 'product-$businessId-${categories[j]}',
          businessId: businessId,
          name: '${categories[j].toUpperCase()} $businessId',
          price: 10.0 + j * 5.0,
          category: categories[j],
          updatedAt: DateTime.now(),
        ),
      );
    }

    // Insert sales (both completed and cancelled)
    await database.transactionDao.insertSale(
      SalesCompanion.insert(
        id: 'sale-completed-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        total: 100.0 + i * 20.0,
        paymentMethod: i.isEven ? 'cash' : 'card',
        timestamp: DateTime.now().subtract(Duration(minutes: i * 10)),
      ),
    );

    await database.transactionDao.insertSale(
      SalesCompanion.insert(
        id: 'sale-cancelled-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        total: 50.0,
        paymentMethod: 'cash',
        status: const Value('cancelled'),
        timestamp: DateTime.now().subtract(Duration(minutes: i * 10 + 5)),
      ),
    );

    // Insert expenses
    await database.transactionDao.insertExpense(
      ExpensesCompanion.insert(
        id: 'expense-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        description: 'Expense for $businessId',
        amount: 20.0 + i * 5.0,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 15)),
      ),
    );

    // Insert corte
    await database.transactionDao.insertCorte(
      CortesCompanion.insert(
        id: 'corte-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        totalCashSales: 100.0,
        totalCardSales: 50.0,
        totalExpenses: 20.0,
        openingBalance: 100.0,
        countedCash: 175.0,
        difference: -5.0,
        closedAt: DateTime.now().subtract(Duration(hours: i)),
      ),
    );
  }
}

/// Verify product isolation between businesses
Future<void> _verifyProductIsolation(
  AppDatabase database,
  String businessA,
  String businessB,
  int testCase,
) async {
  // Query all products for business A
  final productsA = await database.productDao.getAllProductsByBusiness(
    businessA,
  );

  // Verify none of the products belong to business B
  for (final product in productsA) {
    expect(
      product.businessId,
      businessA,
      reason:
          'Test case $testCase: Product ${product.id} should belong to business $businessA',
    );
    expect(
      product.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Product query for business $businessA returned product from business $businessB',
    );
  }

  // Query products by category for business A
  final categories = ['comida', 'bebidas', 'postres'];
  for (final category in categories) {
    final categoryProducts = await database.productDao
        .getProductsByBusinessAndCategory(businessA, category);

    for (final product in categoryProducts) {
      expect(
        product.businessId,
        businessA,
        reason:
            'Test case $testCase: Product ${product.id} in category $category should belong to business $businessA',
      );
      expect(
        product.businessId,
        isNot(businessB),
        reason:
            'Test case $testCase: Category query for business $businessA returned product from business $businessB',
      );
    }
  }
}

/// Verify sales isolation between businesses
Future<void> _verifySalesIsolation(
  AppDatabase database,
  String businessA,
  String businessB,
  int testCase,
) async {
  // Get session for business A
  final sessionA = await database.sessionDao.getActiveSession(businessA);
  if (sessionA == null) return; // No active session to test

  // Query sales for business A
  final salesA = await database.transactionDao.getSalesByBusinessAndSession(
    businessA,
    sessionA.id,
  );

  for (final sale in salesA) {
    expect(
      sale.businessId,
      businessA,
      reason:
          'Test case $testCase: Sale ${sale.id} should belong to business $businessA',
    );
    expect(
      sale.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Sales query for business $businessA returned sale from business $businessB',
    );
  }

  // Query completed sales
  final completedSales = await database.transactionDao
      .getCompletedSalesBySession(businessA, sessionA.id);

  for (final sale in completedSales) {
    expect(
      sale.businessId,
      businessA,
      reason:
          'Test case $testCase: Completed sale ${sale.id} should belong to business $businessA',
    );
    expect(
      sale.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Completed sales query for business $businessA leaked data from business $businessB',
    );
  }
}

/// Verify expenses isolation between businesses
Future<void> _verifyExpensesIsolation(
  AppDatabase database,
  String businessA,
  String businessB,
  int testCase,
) async {
  // Get session for business A
  final sessionA = await database.sessionDao.getActiveSession(businessA);
  if (sessionA == null) return; // No active session to test

  // Query expenses for business A
  final expensesA = await database.transactionDao
      .getExpensesByBusinessAndSession(businessA, sessionA.id);

  for (final expense in expensesA) {
    expect(
      expense.businessId,
      businessA,
      reason:
          'Test case $testCase: Expense ${expense.id} should belong to business $businessA',
    );
    expect(
      expense.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Expenses query for business $businessA returned expense from business $businessB',
    );
  }
}

/// Verify session isolation between businesses
Future<void> _verifySessionIsolation(
  AppDatabase database,
  String businessA,
  String businessB,
  int testCase,
) async {
  // Query active session for business A
  final sessionA = await database.sessionDao.getActiveSession(businessA);

  if (sessionA != null) {
    expect(
      sessionA.businessId,
      businessA,
      reason:
          'Test case $testCase: Active session ${sessionA.id} should belong to business $businessA',
    );
    expect(
      sessionA.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Active session query for business $businessA returned session from business $businessB',
    );
  }

  // Query all sessions for business A
  final sessionsA = await database.sessionDao.getSessionsByBusiness(businessA);

  for (final session in sessionsA) {
    expect(
      session.businessId,
      businessA,
      reason:
          'Test case $testCase: Session ${session.id} should belong to business $businessA',
    );
    expect(
      session.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Sessions query for business $businessA leaked session from business $businessB',
    );
  }
}

/// Verify cortes isolation between businesses
Future<void> _verifyCortesIsolation(
  AppDatabase database,
  String businessA,
  String businessB,
  int testCase,
) async {
  // Query cortes for business A
  final cortesA = await database.transactionDao.getCortesByBusiness(businessA);

  for (final corte in cortesA) {
    expect(
      corte.businessId,
      businessA,
      reason:
          'Test case $testCase: Corte ${corte.id} should belong to business $businessA',
    );
    expect(
      corte.businessId,
      isNot(businessB),
      reason:
          'Test case $testCase: Cortes query for business $businessA returned corte from business $businessB',
    );
  }
}
