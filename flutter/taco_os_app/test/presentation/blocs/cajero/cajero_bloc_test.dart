import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/open_session_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';

// Mock classes
class MockOpenSessionUseCase extends Mock implements OpenSessionUseCase {}

class MockSessionRepository extends Mock implements ISessionRepository {}

// Fake classes for Mocktail
class FakeOpenSessionUseCaseParams extends Fake
    implements OpenSessionUseCaseParams {}

class FakeCloseSessionParams extends Fake implements CloseSessionParams {}

void main() {
  late CajeroBloc cajeroBloc;
  late MockOpenSessionUseCase mockOpenSessionUseCase;
  late MockSessionRepository mockSessionRepository;

  // Test fixtures
  final testSession = CashSession(
    id: 'test-session-id',
    businessId: 'test-business-id',
    userId: 'test-user-id',
    initialCash: 500.0,
    status: SessionStatus.open,
    openedAt: DateTime(2025, 1, 1, 9, 0),
  );

  final testClosedSession = testSession.copyWith(
    status: SessionStatus.closed,
    closedAt: DateTime(2025, 1, 1, 18, 0),
    countedCash: 1500.0,
    difference: 50.0,
  );

  setUpAll(() {
    registerFallbackValue(FakeOpenSessionUseCaseParams());
    registerFallbackValue(FakeCloseSessionParams());
  });

  setUp(() {
    mockOpenSessionUseCase = MockOpenSessionUseCase();
    mockSessionRepository = MockSessionRepository();

    cajeroBloc = CajeroBloc(
      openSessionUseCase: mockOpenSessionUseCase,
      sessionRepository: mockSessionRepository,
    );
  });

  tearDown(() {
    cajeroBloc.close();
  });

  group('CajeroBloc', () {
    test('initial state is CajeroInitial', () {
      expect(cajeroBloc.state, const CajeroInitial());
    });

    group('OpenSessionRequested', () {
      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, TurnoActivo] when session opens successfully',
        build: () {
          when(
            () => mockOpenSessionUseCase(any()),
          ).thenAnswer((_) async => right(testSession));
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const OpenSessionRequested(
            businessId: 'test-business-id',
            userId: 'test-user-id',
            initialCash: 500.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          TurnoActivo(session: testSession),
        ],
        verify: (_) {
          verify(() => mockOpenSessionUseCase(any())).called(1);
        },
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, CajeroError] when validation fails (negative value)',
        build: () {
          when(() => mockOpenSessionUseCase(any())).thenAnswer(
            (_) async => left(
              const ValidationFailure(
                message: 'El fondo de cambio no puede ser negativo',
              ),
            ),
          );
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const OpenSessionRequested(
            businessId: 'test-business-id',
            userId: 'test-user-id',
            initialCash: -100.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          const CajeroError(
            message: 'El fondo de cambio no puede ser negativo',
          ),
        ],
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, CajeroError] when validation fails (exceeds max)',
        build: () {
          when(() => mockOpenSessionUseCase(any())).thenAnswer(
            (_) async => left(
              const ValidationFailure(
                message: 'El fondo de cambio no puede exceder \$999,999.99',
              ),
            ),
          );
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const OpenSessionRequested(
            businessId: 'test-business-id',
            userId: 'test-user-id',
            initialCash: 1000000.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          const CajeroError(
            message: 'El fondo de cambio no puede exceder \$999,999.99',
          ),
        ],
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, CajeroError] when database write fails',
        build: () {
          when(() => mockOpenSessionUseCase(any())).thenAnswer(
            (_) async => left(
              const LocalDatabaseFailure(
                message: 'Error en la base de datos local',
              ),
            ),
          );
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const OpenSessionRequested(
            businessId: 'test-business-id',
            userId: 'test-user-id',
            initialCash: 500.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          const CajeroError(message: 'Error en la base de datos local'),
        ],
      );

      blocTest<CajeroBloc, CajeroState>(
        'accepts zero as valid Fondo_de_Cambio (AC 3.7)',
        build: () {
          final sessionWithZero = testSession.copyWith(initialCash: 0.0);
          when(
            () => mockOpenSessionUseCase(any()),
          ).thenAnswer((_) async => right(sessionWithZero));
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const OpenSessionRequested(
            businessId: 'test-business-id',
            userId: 'test-user-id',
            initialCash: 0.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          TurnoActivo(session: testSession.copyWith(initialCash: 0.0)),
        ],
      );
    });

    group('CloseSessionRequested', () {
      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, TurnoCerrado] when session closes successfully',
        build: () {
          when(
            () => mockSessionRepository.closeSession(any()),
          ).thenAnswer((_) async => right(testClosedSession));
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const CloseSessionRequested(
            sessionId: 'test-session-id',
            countedCash: 1500.0,
          ),
        ),
        expect: () => [const CajeroLoading(), const TurnoCerrado()],
        verify: (_) {
          verify(() => mockSessionRepository.closeSession(any())).called(1);
        },
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, CajeroError] when close fails',
        build: () {
          when(() => mockSessionRepository.closeSession(any())).thenAnswer(
            (_) async => left(
              const LocalDatabaseFailure(message: 'Error al cerrar sesión'),
            ),
          );
          return cajeroBloc;
        },
        act: (bloc) => bloc.add(
          const CloseSessionRequested(
            sessionId: 'test-session-id',
            countedCash: 1500.0,
          ),
        ),
        expect: () => [
          const CajeroLoading(),
          const CajeroError(message: 'Error al cerrar sesión'),
        ],
      );
    });

    group('SessionLoaded', () {
      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, TurnoActivo] when active session exists',
        build: () {
          when(
            () => mockSessionRepository.getActiveSession(any()),
          ).thenAnswer((_) async => right(testSession));
          return cajeroBloc;
        },
        act: (bloc) =>
            bloc.add(const SessionLoaded(businessId: 'test-business-id')),
        expect: () => [
          const CajeroLoading(),
          TurnoActivo(session: testSession),
        ],
        verify: (_) {
          verify(
            () => mockSessionRepository.getActiveSession('test-business-id'),
          ).called(1);
        },
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, TurnoCerrado] when no active session exists',
        build: () {
          when(
            () => mockSessionRepository.getActiveSession(any()),
          ).thenAnswer((_) async => right(null));
          return cajeroBloc;
        },
        act: (bloc) =>
            bloc.add(const SessionLoaded(businessId: 'test-business-id')),
        expect: () => [const CajeroLoading(), const TurnoCerrado()],
        verify: (_) {
          verify(
            () => mockSessionRepository.getActiveSession('test-business-id'),
          ).called(1);
        },
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, TurnoCerrado] when session exists but is closed',
        build: () {
          when(
            () => mockSessionRepository.getActiveSession(any()),
          ).thenAnswer((_) async => right(testClosedSession));
          return cajeroBloc;
        },
        act: (bloc) =>
            bloc.add(const SessionLoaded(businessId: 'test-business-id')),
        expect: () => [const CajeroLoading(), const TurnoCerrado()],
      );

      blocTest<CajeroBloc, CajeroState>(
        'emits [CajeroLoading, CajeroError] when database query fails',
        build: () {
          when(() => mockSessionRepository.getActiveSession(any())).thenAnswer(
            (_) async => left(
              const LocalDatabaseFailure(message: 'Error al consultar sesión'),
            ),
          );
          return cajeroBloc;
        },
        act: (bloc) =>
            bloc.add(const SessionLoaded(businessId: 'test-business-id')),
        expect: () => [
          const CajeroLoading(),
          const CajeroError(message: 'Error al consultar sesión'),
        ],
      );
    });
  });
}
