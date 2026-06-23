import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/network/network_info.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';
import 'package:taco_os_app/infrastructure/datasources/remote/product_remote_data_source.dart';
import 'package:taco_os_app/infrastructure/repositories/product_repository_impl.dart';
import 'package:taco_os_app/infrastructure/repositories/session_repository_impl.dart';
import 'package:taco_os_app/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/domain/entities/expense.dart';

/// **Property 5: Multi-Tenant Isolation**
/// **Validates: Requirements 15.1, 15.2**
///
/// This property test verifies that concrete repository implementations
/// (TransactionRepositoryImpl, ProductRepositoryImpl, SessionRepositoryImpl)
/// properly enforce multi-tenant isolation by filtering all queries by business_id.
///
/// The test ensures that:
/// 1. Repositories never return data from a different business_id
/// 2. All repository methods respect the business_id filter
/// 3. No data leakage occurs across business boundaries
///
/// This test operates at the repository layer (infrastructure), which is one
/// level above the DAO tests. It validates that the repository implementations
/// correctly use the DAO methods with proper business_id filtering.
void main() {
  late AppDatabase database;
  late TransactionRepositoryImpl transactionRepository;
  late ProductRepositoryImpl productRepository;
  late SessionRepositoryImpl sessionRepository;
  final random = Random(42); // Fixed seed for reproducibility

  setUp(() {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());

    // Initialize concrete repository implementations
    transactionRepository = TransactionRepositoryImpl(database: database);

    productRepository = ProductRepositoryImpl(
      productDao: database.productDao,
      remoteDataSource: _MockProductRemoteDataSource(),
      networkInfo: _MockNetworkInfo(isConnected: false),
    );

    sessionRepository = SessionRepositoryImpl(sessionDao: database.sessionDao);
  });

  tearDown(() async {
    await database.close();
  });

  group(
    'Property-Based Test: Multi-Tenant Isolation at Repository Layer (Property 5)',
    () {
      test(
        'Property: TransactionRepository never returns transactions from other businesses',
        () async {
          const numBusinesses = 5;
          const numTestCases = 50;

          // Generate business IDs
          final businessIds = List.generate(
            numBusinesses,
            (i) => 'business-repo-${i + 1}',
          );

          // Setup: Create test data for all businesses
          await _setupMultiTenantData(database, businessIds);

          // Property test: Verify transaction repository isolation
          for (int testCase = 0; testCase < numTestCases; testCase++) {
            // Generate two distinct random business IDs
            final businessA = businessIds[random.nextInt(numBusinesses)];
            String businessB;
            do {
              businessB = businessIds[random.nextInt(numBusinesses)];
            } while (businessA == businessB);

            // Get active session for business A
            final sessionAResult = await sessionRepository.getActiveSession(
              businessA,
            );
            final sessionA = sessionAResult.fold(
              (failure) => throw Exception(
                'Failed to get active session: ${failure.message}',
              ),
              (session) => session,
            );

            if (sessionA == null) continue;

            // Test getPendingSales
            final pendingSalesResult = await transactionRepository
                .getPendingSales(sessionA.id);

            final sales = pendingSalesResult.fold(
              (failure) => throw Exception(
                'Failed to get pending sales: ${failure.message}',
              ),
              (sales) => sales,
            );

            for (final sale in sales) {
              expect(
                sale.businessId,
                businessA,
                reason:
                    'Test case $testCase: TransactionRepository.getPendingSales should only return sales from business $businessA',
              );
              expect(
                sale.businessId,
                isNot(businessB),
                reason:
                    'Test case $testCase: TransactionRepository.getPendingSales leaked data from business $businessB',
              );
            }

            // Test getPendingExpenses
            final pendingExpensesResult = await transactionRepository
                .getPendingExpenses(sessionA.id);

            final expenses = pendingExpensesResult.fold(
              (failure) => throw Exception(
                'Failed to get pending expenses: ${failure.message}',
              ),
              (expenses) => expenses,
            );

            for (final expense in expenses) {
              expect(
                expense.businessId,
                businessA,
                reason:
                    'Test case $testCase: TransactionRepository.getPendingExpenses should only return expenses from business $businessA',
              );
              expect(
                expense.businessId,
                isNot(businessB),
                reason:
                    'Test case $testCase: TransactionRepository.getPendingExpenses leaked data from business $businessB',
              );
            }
          }
        },
      );

      test(
        'Property: ProductRepository never returns products from other businesses',
        () async {
          const numBusinesses = 4;
          const numTestCases = 40;

          final businessIds = List.generate(
            numBusinesses,
            (i) => 'business-prod-${i + 1}',
          );

          await _setupMultiTenantData(database, businessIds);

          // Property test: Verify product repository isolation
          for (int testCase = 0; testCase < numTestCases; testCase++) {
            final businessA = businessIds[random.nextInt(numBusinesses)];
            String businessB;
            do {
              businessB = businessIds[random.nextInt(numBusinesses)];
            } while (businessA == businessB);

            // Test getByCategory for each category
            final categories = [
              ProductCategory.comida,
              ProductCategory.bebidas,
              ProductCategory.postres,
            ];

            for (final category in categories) {
              final productsResult = await productRepository.getByCategory(
                businessA,
                category,
              );

              final products = productsResult.fold(
                (failure) => throw Exception(
                  'Failed to get products: ${failure.message}',
                ),
                (products) => products,
              );

              for (final product in products) {
                expect(
                  product.businessId,
                  businessA,
                  reason:
                      'Test case $testCase: ProductRepository.getByCategory should only return products from business $businessA',
                );
                expect(
                  product.businessId,
                  isNot(businessB),
                  reason:
                      'Test case $testCase: ProductRepository.getByCategory leaked product from business $businessB',
                );
              }
            }
          }
        },
      );

      test(
        'Property: SessionRepository never returns sessions from other businesses',
        () async {
          const numBusinesses = 4;
          const numTestCases = 40;

          final businessIds = List.generate(
            numBusinesses,
            (i) => 'business-sess-${i + 1}',
          );

          await _setupMultiTenantData(database, businessIds);

          // Property test: Verify session repository isolation
          for (int testCase = 0; testCase < numTestCases; testCase++) {
            final businessA = businessIds[random.nextInt(numBusinesses)];
            String businessB;
            do {
              businessB = businessIds[random.nextInt(numBusinesses)];
            } while (businessA == businessB);

            // Test getActiveSession
            final sessionResult = await sessionRepository.getActiveSession(
              businessA,
            );

            final session = sessionResult.fold(
              (failure) => throw Exception(
                'Failed to get active session: ${failure.message}',
              ),
              (session) => session,
            );

            if (session != null) {
              expect(
                session.businessId,
                businessA,
                reason:
                    'Test case $testCase: SessionRepository.getActiveSession should only return session from business $businessA',
              );
              expect(
                session.businessId,
                isNot(businessB),
                reason:
                    'Test case $testCase: SessionRepository.getActiveSession returned session from business $businessB',
              );
            }
          }
        },
      );

      test(
        'Property: saveSale in TransactionRepository associates sale with correct business_id',
        () async {
          const numBusinesses = 3;
          const numTestCases = 30;

          final businessIds = List.generate(
            numBusinesses,
            (i) => 'business-save-${i + 1}',
          );

          await _setupMultiTenantData(database, businessIds);

          // Property test: Verify saved sales are associated with the correct business
          for (int testCase = 0; testCase < numTestCases; testCase++) {
            final businessA = businessIds[random.nextInt(numBusinesses)];

            // Get active session for business A
            final sessionAResult = await sessionRepository.getActiveSession(
              businessA,
            );

            final sessionA = sessionAResult.fold(
              (failure) => throw Exception(
                'Failed to get active session: ${failure.message}',
              ),
              (session) => session,
            );

            if (sessionA == null) continue;

            // Create a sale for business A
            final sale = Sale(
              id: 'sale-test-$testCase-$businessA',
              sessionId: sessionA.id,
              businessId: businessA,
              cashierId: 'cashier-$businessA',
              items: [
                SaleItem(
                  productId: 'product-1',
                  productName: 'Test Product',
                  quantity: 1,
                  unitPrice: 10.0,
                  subtotal: 10.0,
                ),
              ],
              total: 10.0,
              paymentMethod: PaymentMethod.cash,
              status: SaleStatus.completed,
              timestamp: DateTime.now(),
              isSynced: false,
            );

            // Save the sale
            final saveResult = await transactionRepository.saveSale(sale);

            final savedSale = saveResult.fold(
              (failure) =>
                  throw Exception('Failed to save sale: ${failure.message}'),
              (saved) => saved,
            );

            // Verify the saved sale has the correct business_id
            expect(
              savedSale.businessId,
              businessA,
              reason:
                  'Test case $testCase: Saved sale should belong to business $businessA',
            );

            // Retrieve pending sales and verify isolation
            final pendingSalesResult = await transactionRepository
                .getPendingSales(sessionA.id);

            final sales = pendingSalesResult.fold(
              (failure) => throw Exception(
                'Failed to get pending sales: ${failure.message}',
              ),
              (sales) => sales,
            );

            final savedSaleInList = sales.firstWhere(
              (s) => s.id == sale.id,
              orElse: () =>
                  throw Exception('Saved sale not found in pending list'),
            );

            expect(
              savedSaleInList.businessId,
              businessA,
              reason:
                  'Test case $testCase: Retrieved sale should belong to business $businessA',
            );
          }
        },
      );

      test(
        'Property: saveExpense in TransactionRepository associates expense with correct business_id',
        () async {
          const numBusinesses = 3;
          const numTestCases = 30;

          final businessIds = List.generate(
            numBusinesses,
            (i) => 'business-exp-${i + 1}',
          );

          await _setupMultiTenantData(database, businessIds);

          // Property test: Verify saved expenses are associated with the correct business
          for (int testCase = 0; testCase < numTestCases; testCase++) {
            final businessA = businessIds[random.nextInt(numBusinesses)];

            // Get active session for business A
            final sessionAResult = await sessionRepository.getActiveSession(
              businessA,
            );

            final sessionA = sessionAResult.fold(
              (failure) => throw Exception(
                'Failed to get active session: ${failure.message}',
              ),
              (session) => session,
            );

            if (sessionA == null) continue;

            // Create an expense for business A
            final expense = Expense(
              id: 'expense-test-$testCase-$businessA',
              sessionId: sessionA.id,
              businessId: businessA,
              cashierId: 'cashier-$businessA',
              description: 'Test expense $testCase',
              amount: 50.0,
              timestamp: DateTime.now(),
              isSynced: false,
            );

            // Save the expense
            final saveResult = await transactionRepository.saveExpense(expense);

            final savedExpense = saveResult.fold(
              (failure) =>
                  throw Exception('Failed to save expense: ${failure.message}'),
              (saved) => saved,
            );

            // Verify the saved expense has the correct business_id
            expect(
              savedExpense.businessId,
              businessA,
              reason:
                  'Test case $testCase: Saved expense should belong to business $businessA',
            );

            // Retrieve pending expenses and verify isolation
            final pendingExpensesResult = await transactionRepository
                .getPendingExpenses(sessionA.id);

            final expenses = pendingExpensesResult.fold(
              (failure) => throw Exception(
                'Failed to get pending expenses: ${failure.message}',
              ),
              (expenses) => expenses,
            );

            final savedExpenseInList = expenses.firstWhere(
              (e) => e.id == expense.id,
              orElse: () =>
                  throw Exception('Saved expense not found in pending list'),
            );

            expect(
              savedExpenseInList.businessId,
              businessA,
              reason:
                  'Test case $testCase: Retrieved expense should belong to business $businessA',
            );
          }
        },
      );
    },
  );
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

    // Insert sales (both completed and pending sync)
    await database.transactionDao.insertSale(
      SalesCompanion.insert(
        id: 'sale-completed-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        total: 100.0 + i * 20.0,
        paymentMethod: i.isEven ? 'cash' : 'card',
        isSynced: const Value(false), // Pending sync
        timestamp: DateTime.now().subtract(Duration(minutes: i * 10)),
      ),
    );

    // Insert expenses (pending sync)
    await database.transactionDao.insertExpense(
      ExpensesCompanion.insert(
        id: 'expense-$businessId',
        sessionId: sessionId,
        businessId: businessId,
        cashierId: cashierId,
        description: 'Expense for $businessId',
        amount: 20.0 + i * 5.0,
        isSynced: const Value(false), // Pending sync
        timestamp: DateTime.now().subtract(Duration(minutes: i * 15)),
      ),
    );
  }
}

/// Mock implementation of NetworkInfo for testing
class _MockNetworkInfo implements NetworkInfo {
  final bool _isConnected;

  _MockNetworkInfo({required bool isConnected}) : _isConnected = isConnected;

  @override
  Future<bool> get isConnected async => _isConnected;
}

/// Mock implementation of IProductRemoteDataSource for testing
class _MockProductRemoteDataSource implements IProductRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String token,
    String businessId,
    String category,
  ) async {
    // Return empty list for testing (we're testing offline behavior)
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> syncCatalog(
    String token,
    String businessId,
  ) async {
    // Return empty list for testing (we're testing offline behavior)
    return [];
  }
}
