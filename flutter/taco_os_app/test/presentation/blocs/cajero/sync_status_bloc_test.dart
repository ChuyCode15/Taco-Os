import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/network/network_info.dart';
import 'package:taco_os_app/domain/entities/expense.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_state.dart';

// Mock classes
class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late SyncStatusBloc syncStatusBloc;
  late MockNetworkInfo mockNetworkInfo;
  late MockTransactionRepository mockTransactionRepository;
  late MockConnectivity mockConnectivity;

  const testSessionId = 'session-123';

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockTransactionRepository = MockTransactionRepository();
    mockConnectivity = MockConnectivity();

    // Mock connectivity stream
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());

    syncStatusBloc = SyncStatusBloc(
      networkInfo: mockNetworkInfo,
      transactionRepository: mockTransactionRepository,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    syncStatusBloc.close();
  });

  group('SyncStatusBloc', () {
    test('initial state is SyncOffline', () {
      expect(syncStatusBloc.state, const SyncOffline());
    });

    group('CheckSyncStatus', () {
      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncOffline] when there is no connectivity',
        build: () {
          when(
            () => mockNetworkInfo.isConnected,
          ).thenAnswer((_) async => false);
          return syncStatusBloc;
        },
        act: (bloc) =>
            bloc.add(const CheckSyncStatus(sessionId: testSessionId)),
        expect: () => [const SyncOffline()],
      );

      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncSynced] when connected and no pending transactions',
        build: () {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            () => mockTransactionRepository.getPendingSales(testSessionId),
          ).thenAnswer((_) async => right(<Sale>[]));
          when(
            () => mockTransactionRepository.getPendingExpenses(testSessionId),
          ).thenAnswer((_) async => right(<Expense>[]));
          return syncStatusBloc;
        },
        act: (bloc) =>
            bloc.add(const CheckSyncStatus(sessionId: testSessionId)),
        expect: () => [const SyncSynced()],
      );

      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncPending] when connected and has pending sales',
        build: () {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            () => mockTransactionRepository.getPendingSales(testSessionId),
          ).thenAnswer(
            (_) async => right([
              // Mock sale (simplified)
              Sale(
                id: 'sale-1',
                sessionId: testSessionId,
                businessId: 'biz-123',
                cashierId: 'user-456',
                items: const [],
                total: 100.0,
                paymentMethod: PaymentMethod.cash,
                status: SaleStatus.completed,
                timestamp: DateTime.now(),
                isSynced: false,
              ),
            ]),
          );
          when(
            () => mockTransactionRepository.getPendingExpenses(testSessionId),
          ).thenAnswer((_) async => right(<Expense>[]));
          return syncStatusBloc;
        },
        act: (bloc) =>
            bloc.add(const CheckSyncStatus(sessionId: testSessionId)),
        expect: () => [const SyncPending(pendingCount: 1)],
      );

      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncPending] when connected and has pending expenses',
        build: () {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            () => mockTransactionRepository.getPendingSales(testSessionId),
          ).thenAnswer((_) async => right(<Sale>[]));
          when(
            () => mockTransactionRepository.getPendingExpenses(testSessionId),
          ).thenAnswer(
            (_) async => right([
              Expense(
                id: 'expense-1',
                sessionId: testSessionId,
                businessId: 'biz-123',
                cashierId: 'user-456',
                description: 'Test expense',
                amount: 50.0,
                timestamp: DateTime.now(),
                isSynced: false,
              ),
            ]),
          );
          return syncStatusBloc;
        },
        act: (bloc) =>
            bloc.add(const CheckSyncStatus(sessionId: testSessionId)),
        expect: () => [const SyncPending(pendingCount: 1)],
      );

      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncOffline] when both queries fail',
        build: () {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            () => mockTransactionRepository.getPendingSales(testSessionId),
          ).thenAnswer(
            (_) async => left(const LocalDatabaseFailure(message: 'DB error')),
          );
          when(
            () => mockTransactionRepository.getPendingExpenses(testSessionId),
          ).thenAnswer(
            (_) async => left(const LocalDatabaseFailure(message: 'DB error')),
          );
          return syncStatusBloc;
        },
        act: (bloc) =>
            bloc.add(const CheckSyncStatus(sessionId: testSessionId)),
        expect: () => [const SyncOffline()],
      );
    });

    group('ConnectivityChanged', () {
      blocTest<SyncStatusBloc, SyncStatusState>(
        'emits [SyncOffline] when connectivity is lost',
        build: () => syncStatusBloc,
        act: (bloc) => bloc.add(
          const ConnectivityChanged(results: [ConnectivityResult.none]),
        ),
        expect: () => [const SyncOffline()],
      );

      blocTest<SyncStatusBloc, SyncStatusState>(
        'does not emit duplicate states when connectivity changes but state remains same',
        build: () {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            () => mockTransactionRepository.getPendingSales(testSessionId),
          ).thenAnswer((_) async => right(<Sale>[]));
          when(
            () => mockTransactionRepository.getPendingExpenses(testSessionId),
          ).thenAnswer((_) async => right(<Expense>[]));
          return syncStatusBloc;
        },
        act: (bloc) {
          // First, set a session
          bloc.add(const CheckSyncStatus(sessionId: testSessionId));
          // Then simulate connectivity change
          return Future.delayed(
            const Duration(milliseconds: 100),
            () => bloc.add(
              const ConnectivityChanged(results: [ConnectivityResult.wifi]),
            ),
          );
        },
        expect: () => [
          const SyncSynced(), // From CheckSyncStatus (no duplicate from ConnectivityChanged)
        ],
      );
    });
  });
}
