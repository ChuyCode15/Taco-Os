import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/network/network_info.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';
import 'package:taco_os_app/domain/repositories/i_product_repository.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/domain/usecases/auth/check_session_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/cancel_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_expense_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/catalog/get_products_by_category_use_case.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';
import 'package:taco_os_app/infrastructure/datasources/local/daos/product_dao.dart';
import 'package:taco_os_app/infrastructure/datasources/local/daos/session_dao.dart';
import 'package:taco_os_app/infrastructure/datasources/local/daos/transaction_dao.dart';
import 'package:taco_os_app/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:taco_os_app/infrastructure/datasources/remote/product_remote_data_source.dart';
import 'package:taco_os_app/infrastructure/datasources/remote/transaction_remote_data_source.dart';
import 'package:taco_os_app/infrastructure/services/secure_storage_service.dart';
import 'package:taco_os_app/injection_container.dart' as di;

/// Test suite for the dependency injection container
///
/// Validates that all dependencies are properly registered and can be resolved.
/// This test ensures compliance with Requirement 13.5.
///
/// **Note:** Tests that require platform channels (like AppDatabase instances)
/// only verify registration, not actual instantiation, as platform channels
/// aren't available in unit tests.
///
/// **Validates: Requirement 13.5** - Dependency injection container
void main() {
  // Initialize Flutter bindings for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection Container', () {
    setUpAll(() async {
      // Initialize the DI container before running tests
      await di.init();
    });

    tearDownAll(() async {
      // Clean up the DI container after tests
      await di.sl.reset();
    });

    group('Core Services', () {
      test('NetworkInfo is registered and returns singleton', () {
        final networkInfo1 = di.sl<NetworkInfo>();
        final networkInfo2 = di.sl<NetworkInfo>();

        expect(networkInfo1, isNotNull);
        expect(networkInfo1, equals(networkInfo2));
      });

      test('SecureStorageService is registered and returns singleton', () {
        final storage1 = di.sl<ISecureStorageService>();
        final storage2 = di.sl<ISecureStorageService>();

        expect(storage1, isNotNull);
        expect(storage1, equals(storage2));
      });
    });

    group('Data Sources', () {
      test('AppDatabase is registered (platform channel test skipped)', () {
        expect(di.sl.isRegistered<AppDatabase>(), isTrue);
      });

      test('DAOs are registered', () {
        expect(di.sl.isRegistered<TransactionDao>(), isTrue);
        expect(di.sl.isRegistered<ProductDao>(), isTrue);
        expect(di.sl.isRegistered<SessionDao>(), isTrue);
      });

      test('Remote data sources are registered and return singletons', () {
        final authDs1 = di.sl<IAuthRemoteDataSource>();
        final authDs2 = di.sl<IAuthRemoteDataSource>();
        expect(authDs1, equals(authDs2));

        final productDs1 = di.sl<IProductRemoteDataSource>();
        final productDs2 = di.sl<IProductRemoteDataSource>();
        expect(productDs1, equals(productDs2));

        final transactionDs1 = di.sl<ITransactionRemoteDataSource>();
        final transactionDs2 = di.sl<ITransactionRemoteDataSource>();
        expect(transactionDs1, equals(transactionDs2));
      });
    });

    group('Repositories', () {
      test('IAuthRepository is registered and returns singleton', () {
        final repo1 = di.sl<IAuthRepository>();
        final repo2 = di.sl<IAuthRepository>();

        expect(repo1, isNotNull);
        expect(repo1, equals(repo2));
      });

      test('ITransactionRepository is registered', () {
        expect(di.sl.isRegistered<ITransactionRepository>(), isTrue);
      });

      test('IProductRepository is registered and returns singleton', () {
        final repo1 = di.sl<IProductRepository>();
        final repo2 = di.sl<IProductRepository>();

        expect(repo1, isNotNull);
        expect(repo1, equals(repo2));
      });
    });

    group('Use Cases', () {
      test('Auth use cases are registered and return singletons', () {
        final signIn1 = di.sl<SignInUseCase>();
        final signIn2 = di.sl<SignInUseCase>();
        expect(signIn1, equals(signIn2));

        final signOut1 = di.sl<SignOutUseCase>();
        final signOut2 = di.sl<SignOutUseCase>();
        expect(signOut1, equals(signOut2));

        final checkSession1 = di.sl<CheckSessionUseCase>();
        final checkSession2 = di.sl<CheckSessionUseCase>();
        expect(checkSession1, equals(checkSession2));
      });

      test('Cajero use cases are registered and return singletons', () {
        final registerSale1 = di.sl<RegisterSaleUseCase>();
        final registerSale2 = di.sl<RegisterSaleUseCase>();
        expect(registerSale1, equals(registerSale2));

        final registerExpense1 = di.sl<RegisterExpenseUseCase>();
        final registerExpense2 = di.sl<RegisterExpenseUseCase>();
        expect(registerExpense1, equals(registerExpense2));

        final cancelSale1 = di.sl<CancelSaleUseCase>();
        final cancelSale2 = di.sl<CancelSaleUseCase>();
        expect(cancelSale1, equals(cancelSale2));
      });

      test('Catalog use cases are registered and return singletons', () {
        final getProducts1 = di.sl<GetProductsByCategoryUseCase>();
        final getProducts2 = di.sl<GetProductsByCategoryUseCase>();
        expect(getProducts1, equals(getProducts2));
      });
    });

    group('Clean Architecture Principles', () {
      test('Repositories are injected as abstract interfaces', () {
        final authRepo = di.sl<IAuthRepository>();
        final transactionRepo = di.sl<ITransactionRepository>();
        final productRepo = di.sl<IProductRepository>();

        expect(authRepo, isA<IAuthRepository>());
        expect(transactionRepo, isA<ITransactionRepository>());
        expect(productRepo, isA<IProductRepository>());
      });

      test('Use cases are properly initialized with dependencies', () {
        final registerSaleUseCase = di.sl<RegisterSaleUseCase>();
        final registerExpenseUseCase = di.sl<RegisterExpenseUseCase>();
        final signInUseCase = di.sl<SignInUseCase>();

        expect(registerSaleUseCase, isNotNull);
        expect(registerExpenseUseCase, isNotNull);
        expect(signInUseCase, isNotNull);
      });
    });
  });
}
