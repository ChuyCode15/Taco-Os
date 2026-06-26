import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Core
import 'core/constants/api_endpoints.dart';
import 'core/network/network_info.dart';

// Domain - Repositories
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_product_repository.dart';
import 'domain/repositories/i_session_repository.dart';
import 'domain/repositories/i_transaction_repository.dart';

// Domain - Use Cases - Auth
import 'domain/usecases/auth/check_session_use_case.dart';
import 'domain/usecases/auth/sign_in_use_case.dart';
import 'domain/usecases/auth/sign_out_use_case.dart';

// Domain - Use Cases - Cajero
import 'domain/usecases/cajero/cancel_sale_use_case.dart';
import 'domain/usecases/cajero/close_session_use_case.dart';
import 'domain/usecases/cajero/get_shift_summary_use_case.dart';
import 'domain/usecases/cajero/open_session_use_case.dart';
import 'domain/usecases/cajero/register_expense_use_case.dart';
import 'domain/usecases/cajero/register_sale_use_case.dart';

// Domain - Use Cases - Catalog
import 'domain/usecases/catalog/get_products_by_category_use_case.dart';

// Infrastructure - Data Sources
import 'infrastructure/datasources/local/app_database.dart';
import 'infrastructure/datasources/local/daos/product_dao.dart';
import 'infrastructure/datasources/local/daos/session_dao.dart';
import 'infrastructure/datasources/local/daos/transaction_dao.dart';
import 'infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'infrastructure/datasources/remote/product_remote_data_source.dart';
import 'infrastructure/datasources/remote/transaction_remote_data_source.dart';

// Infrastructure - Repositories
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/product_repository_impl.dart';
import 'infrastructure/repositories/session_repository_impl.dart';
import 'infrastructure/repositories/transaction_repository_impl.dart';

// Infrastructure - Services
import 'infrastructure/services/secure_storage_service.dart';
import 'infrastructure/services/sync_service.dart';

// Presentation - BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/cajero/cajero_bloc_exports.dart';
import 'presentation/blocs/cajero/gastos_bloc.dart';
import 'presentation/blocs/patron/patron_bloc.dart';

// Presentation - Router
import 'presentation/router/app_router.dart';

/// Global service-locator instance.
final GetIt sl = GetIt.instance;

/// Registers all application dependencies.
///
/// Called once from [main] before [runApp].
/// Follows Clean Architecture principles with proper dependency injection.
///
/// **Registration Strategy:**
/// - Services, NetworkInfo, and SyncService: lazy singleton (single instance)
/// - Data sources (local and remote): lazy singleton
/// - Repositories: lazy singleton (injected as abstract interfaces)
/// - Use cases: lazy singleton
/// - BLoCs: factory (new instance per request) - to be added in future tasks
///
/// **Validates: Requirement 13.5** - Dependency injection container
Future<void> init() async {
  // =========================================================================
  // CORE SERVICES
  // =========================================================================

  // Network connectivity checker
  // Requirement 10.10: Detect connectivity changes for sync status
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // External dependencies for NetworkInfo
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // SecureStorageService - Manages JWT storage in Keychain/Keystore
  // Requirement 1.2, 15.5: JWT stored exclusively in secure OS storage
  sl.registerLazySingleton<ISecureStorageService>(
    () => SecureStorageServiceImpl(storage: const FlutterSecureStorage()),
  );

  // AppRouter - Central router with auth and role guards
  // Requirement 2.1, 3.5, 4.1: Navigation with guards
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(
      authRepository: sl<IAuthRepository>(),
      sessionRepository: sl<ISessionRepository>(),
    ),
  );

  // SyncService - Background synchronization service
  // Requirement 10.3: Batch synchronization every 5 minutes
  // Requirement 11.2: Catalog synchronization on startup
  sl.registerLazySingleton<ISyncService>(
    () => SyncServiceImpl(
      database: sl<AppDatabase>(),
      remoteDataSource: sl<ITransactionRemoteDataSource>(),
      secureStorage: sl<ISecureStorageService>(),
      networkInfo: sl<NetworkInfo>(),
      productRepository: sl<IProductRepository>(),
    ),
  );

  // =========================================================================
  // EXTERNAL DEPENDENCIES
  // =========================================================================

  // Dio HTTP client - Used by all remote data sources
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // Add interceptors for logging or auth refresh if needed
    return dio;
  });

  // Google Sign-In - Used by auth remote data source
  // Requirement 1.1: Google Sign-In authentication
  // Note: On Android, use serverClientId (not clientId) — Android ignores clientId
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      serverClientId:
          '304760822312-u7165470ass1n776no12r6amnjtg5q93.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    ),
  );

  // =========================================================================
  // DATA SOURCES - LOCAL (SQLite/Drift)
  // =========================================================================

  // AppDatabase - Main SQLite database instance
  // Requirement 10.1, 10.2: Local database for offline-first operation
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // TransactionDao - Data access object for transactions (sales, expenses, cortes)
  sl.registerLazySingleton<TransactionDao>(
    () => TransactionDao(sl<AppDatabase>()),
  );

  // ProductDao - Data access object for products catalog
  sl.registerLazySingleton<ProductDao>(() => ProductDao(sl<AppDatabase>()));

  // SessionDao - Data access object for cash sessions
  sl.registerLazySingleton<SessionDao>(() => SessionDao(sl<AppDatabase>()));

  // =========================================================================
  // DATA SOURCES - REMOTE (REST API)
  // =========================================================================

  // Auth remote data source
  // Requirement 1.1: Google Sign-In and JWT exchange with backend
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Product remote data source
  // Requirement 11.2: Catalog synchronization with backend
  sl.registerLazySingleton<IProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Transaction remote data source
  // Requirement 10.3: Batch synchronization of transactions
  sl.registerLazySingleton<ITransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // =========================================================================
  // REPOSITORIES (Concrete implementations injected as abstract interfaces)
  // =========================================================================

  // Auth repository
  // Requirement 1.1, 1.2, 1.9: Authentication, JWT storage, sign out
  // Requirement 13.2: Injected as abstract interface
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      dio: sl<Dio>(),
      secureStorage: sl<ISecureStorageService>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Transaction repository
  // Requirement 5.6, 6.4, 7.2, 9.4: Sales, cancellations, expenses, cortes
  // Requirement 13.2: Injected as abstract interface
  sl.registerLazySingleton<ITransactionRepository>(
    () => TransactionRepositoryImpl(database: sl<AppDatabase>()),
  );

  // Product repository
  // Requirement 11.1, 11.2: Offline catalog and synchronization
  // Requirement 13.2: Injected as abstract interface
  sl.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      productDao: sl<ProductDao>(),
      remoteDataSource: sl<IProductRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Session repository
  // Requirement 3.2, 3.5, 8.1, 9.4: Session management and shift summary
  // Requirement 13.2: Injected as abstract interface
  sl.registerLazySingleton<ISessionRepository>(
    () => SessionRepositoryImpl(sessionDao: sl<SessionDao>()),
  );

  // =========================================================================
  // USE CASES
  // =========================================================================

  // ─── Auth Use Cases ──────────────────────────────────────────────────────

  // Requirement 1.1, 1.2: Sign in with Google
  sl.registerLazySingleton(() => SignInUseCase(sl<IAuthRepository>()));

  // Requirement 1.9: Sign out
  sl.registerLazySingleton(() => SignOutUseCase(sl<IAuthRepository>()));

  // Requirement 1.6, 1.7, 1.8: Check session validity
  sl.registerLazySingleton(() => CheckSessionUseCase(sl<IAuthRepository>()));

  // ─── Cajero Use Cases ────────────────────────────────────────────────────

  // Requirement 3.2: Open cash session (inicio de turno)
  sl.registerLazySingleton(() => OpenSessionUseCase(sl<ISessionRepository>()));

  // Requirement 5.6: Register sale
  sl.registerLazySingleton(
    () => RegisterSaleUseCase(sl<ITransactionRepository>()),
  );

  // Requirement 7.2: Register expense
  sl.registerLazySingleton(
    () => RegisterExpenseUseCase(sl<ITransactionRepository>()),
  );

  // Requirement 6.4: Cancel sale with photo
  sl.registerLazySingleton(
    () => CancelSaleUseCase(sl<ITransactionRepository>()),
  );

  // Requirement 9.4: Close session (corte de caja)
  sl.registerLazySingleton(() => CloseSessionUseCase(sl<ISessionRepository>()));

  // Requirement 8.1: Get shift summary (¿Cómo voy?)
  sl.registerLazySingleton(
    () => GetShiftSummaryUseCase(sl<ISessionRepository>()),
  );

  // ─── Catalog Use Cases ───────────────────────────────────────────────────

  // Requirement 5.1, 11.1: Get products by category
  sl.registerLazySingleton(
    () => GetProductsByCategoryUseCase(sl<IProductRepository>()),
  );

  // ─── Sync Use Cases ──────────────────────────────────────────────────────

  // Requirement 10.3: Sync pending transactions
  // TODO: To be implemented in a future task (requires SyncService and use case implementation)
  // sl.registerLazySingleton(() => SyncPendingTransactionsUseCase(sl<ISyncRepository>()));

  // =========================================================================
  // BLoCs (Factory registration - new instance per request)
  // =========================================================================

  // NOTE: BLoCs should use registerFactory() to create new instances per request.
  // This ensures each widget tree gets its own BLoC instance.

  // ─── Auth BLoC ───────────────────────────────────────────────────────────
  // Requirement 1.1, 1.3, 1.5, 1.6, 1.7, 1.9: Authentication lifecycle
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl<SignInUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      checkSessionUseCase: sl<CheckSessionUseCase>(),
      authRepository: sl<IAuthRepository>(),
    ),
  );

  // ─── Cajero BLoCs ────────────────────────────────────────────────────────

  // Requirement 3.1, 3.2, 3.5: Cajero session lifecycle
  sl.registerFactory(
    () => CajeroBloc(
      openSessionUseCase: sl<OpenSessionUseCase>(),
      sessionRepository: sl<ISessionRepository>(),
    ),
  );

  // Requirement 10.10: Sync status indicator for Modo_Cajero
  sl.registerFactory(
    () => SyncStatusBloc(
      networkInfo: sl<NetworkInfo>(),
      transactionRepository: sl<ITransactionRepository>(),
      connectivity: sl<Connectivity>(),
    ),
  );

  // Requirement 7.1, 7.2, 7.3, 7.4, 7.5, 7.6: Register expenses
  sl.registerFactory(
    () => GastosBloc(registerExpenseUseCase: sl<RegisterExpenseUseCase>()),
  );

  // ─── Patron BLoC ─────────────────────────────────────────────────────────
  // Requirement 12.1, 12.2, 12.3, 12.4, 12.5: Dashboard del Patron
  sl.registerFactory(() => PatronBloc(database: sl<AppDatabase>()));

  // TODO: Additional BLoCs to be added in future tasks
  //
  // ─── Ventas, Corte BLoCs ─────────────────────────────────────────────
  //
  // sl.registerFactory(() => VentasBloc(
  //   registerSale: sl<RegisterSaleUseCase>(),
  //   cancelSale: sl<CancelSaleUseCase>(),
  //   getProducts: sl<GetProductsByCategoryUseCase>(),
  // ));
  //
  // sl.registerFactory(() => CorteBloc(
  //   closeSession: sl<CloseSessionUseCase>(),
  //   getShiftSummary: sl<GetShiftSummaryUseCase>(),
  // ));
}
