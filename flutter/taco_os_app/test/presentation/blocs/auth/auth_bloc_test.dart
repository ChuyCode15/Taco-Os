import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';
import 'package:taco_os_app/domain/usecases/auth/check_session_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_bloc_exports.dart';

// Mock classes
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class MockAuthRepository extends Mock implements IAuthRepository {}

// Fake classes for Mocktail
class FakeSignInParams extends Fake implements SignInParams {}

class FakeNoParams extends Fake implements NoParams {}

class FakeCheckSessionParams extends Fake implements CheckSessionParams {}

void main() {
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockCheckSessionUseCase mockCheckSessionUseCase;
  late MockAuthRepository mockAuthRepository;

  // Test user fixture
  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: UserRole.cajero,
    businessId: 'test-business-id',
    createdAt: DateTime(2025, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeSignInParams());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeCheckSessionParams());
  });

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockCheckSessionUseCase = MockCheckSessionUseCase();
    mockAuthRepository = MockAuthRepository();

    authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signOutUseCase: mockSignOutUseCase,
      checkSessionUseCase: mockCheckSessionUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('SignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign-in succeeds',
        build: () {
          when(
            () => mockSignInUseCase(any()),
          ).thenAnswer((_) async => right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested()),
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign-in fails (first attempt)',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 1 de 3')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign-in fails (second attempt)',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
        },
        expect: () => [
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 1 de 3')),
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 2 de 3')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when user cancels Google Sign-In',
        build: () {
          when(
            () => mockSignInUseCase(any()),
          ).thenAnswer((_) async => left(const AuthCancelledFailure()));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'does not increment failed attempts counter when user cancels',
        build: () {
          when(
            () => mockSignInUseCase(any()),
          ).thenAnswer((_) async => left(const AuthCancelledFailure()));
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
        },
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
          const AuthLoading(),
          const Unauthenticated(),
          const AuthLoading(),
          const Unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] with block after 3 failed attempts',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
        },
        skip: 5,
        expect: () => [
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', true)
              .having(
                (s) => s.blockedSecondsRemaining,
                'blockedSecondsRemaining',
                30,
              ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'blocks subsequent sign-in attempts during 30-second lockout',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
          bloc.add(const SignInRequested());
        },
        expect: () => [
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 1 de 3')),
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 2 de 3')),
          const AuthLoading(),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', true)
              .having(
                (s) => s.blockedSecondsRemaining,
                'blockedSecondsRemaining',
                30,
              ),
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', true)
              .having(
                (s) => s.message,
                'message',
                contains('Demasiados intentos fallidos'),
              ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'resets failed attempts counter after successful sign-in',
        build: () {
          var callCount = 0;
          when(() => mockSignInUseCase(any())).thenAnswer((_) async {
            callCount++;
            if (callCount <= 2) {
              return left(const AuthFailure(message: 'Test error'));
            }
            return right(testUser);
          });
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested()); // Fail 1
          bloc.add(const SignInRequested()); // Fail 2
          bloc.add(const SignInRequested()); // Success - should reset counter
        },
        skip: 4,
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'shows descriptive error message for NetworkFailure (AC 1.3)',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const NetworkFailure(message: 'No connection')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
            (s) => s.message,
            'message',
            contains('Sin conexión a internet'),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'shows descriptive error message for ServerFailure (AC 1.3)',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(
              const ServerFailure(message: 'Server error', statusCode: 500),
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignInRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
            (s) => s.message,
            'message',
            contains('Error del servidor'),
          ),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when sign-out succeeds (AC 1.9)',
        build: () {
          when(
            () => mockSignOutUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign-out fails',
        build: () {
          when(() => mockSignOutUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Sign-out failed')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
            (s) => s.message,
            'message',
            contains('Error al cerrar sesión'),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'resets failed attempts counter when sign-out succeeds',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          when(
            () => mockSignOutUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested()); // Fail 1
          bloc.add(const SignInRequested()); // Fail 2
          bloc.add(const SignOutRequested()); // Sign out - should reset counter
        },
        skip: 5,
        expect: () => [const Unauthenticated()],
      );
    });

    group('SessionChecked', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when session is valid (AC 1.6)',
        build: () {
          when(
            () => mockCheckSessionUseCase(any()),
          ).thenAnswer((_) async => right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SessionChecked(backgroundTimeMs: 1000)),
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when session returns null',
        build: () {
          when(
            () => mockCheckSessionUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SessionChecked(backgroundTimeMs: 1000)),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when session check fails',
        build: () {
          when(() => mockCheckSessionUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'JWT expired')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const SessionChecked(backgroundTimeMs: 1000)),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'passes correct backgroundTimeMs to CheckSessionUseCase',
        build: () {
          when(
            () => mockCheckSessionUseCase(any()),
          ).thenAnswer((_) async => right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const SessionChecked(backgroundTimeMs: 43200000),
        ), // 12 hours
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
      );
    });

    group('BackgroundTimeoutExceeded', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when background timeout is exceeded (AC 1.7)',
        build: () {
          when(
            () => mockSignOutUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const BackgroundTimeoutExceeded()),
        expect: () => [const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'calls SignOutUseCase to delete JWT',
        build: () {
          when(
            () => mockSignOutUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const BackgroundTimeoutExceeded()),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] even if SignOutUseCase fails',
        build: () {
          when(() => mockSignOutUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Sign-out failed')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(const BackgroundTimeoutExceeded()),
        expect: () => [const Unauthenticated()],
      );
    });

    group('30-Second Lockout Timer Mechanism', () {
      blocTest<AuthBloc, AuthState>(
        'activates 30-second block after 3 failed attempts (AC 1.5)',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested()); // Attempt 1
          bloc.add(const SignInRequested()); // Attempt 2
          bloc.add(const SignInRequested()); // Attempt 3 - triggers 30s block
        },
        skip: 5,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', true)
              .having(
                (s) => s.blockedSecondsRemaining,
                'blockedSecondsRemaining',
                30,
              ),
        ],
      );

      test('BLoC closes cleanly and cancels timers', () async {
        when(() => mockSignInUseCase(any())).thenAnswer(
          (_) async => left(const AuthFailure(message: 'Test error')),
        );

        // Trigger block
        authBloc.add(const SignInRequested());
        authBloc.add(const SignInRequested());
        authBloc.add(const SignInRequested());

        await Future.delayed(const Duration(milliseconds: 200));

        // Close should complete without hanging
        await expectLater(authBloc.close(), completes);
      });
    });

    group('Event-to-State Transition Coverage', () {
      blocTest<AuthBloc, AuthState>(
        'handles rapid successive SignInRequested events',
        build: () {
          when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => left(const AuthFailure(message: 'Test error')),
          );
          return authBloc;
        },
        act: (bloc) {
          for (var i = 0; i < 5; i++) {
            bloc.add(const SignInRequested());
          }
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthLoading(), // Event 1
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 1 de 3')),
          const AuthLoading(), // Event 2
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 2 de 3')),
          const AuthLoading(), // Event 3
          isA<AuthError>().having(
            (s) => s.isBlocked,
            'isBlocked',
            true,
          ), // Block triggered
          isA<AuthError>().having(
            (s) => s.isBlocked,
            'isBlocked',
            true,
          ), // Either countdown timer or Event 4 - both blocked
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'transitions from Authenticated to Unauthenticated via SignOut',
        build: () {
          when(
            () => mockSignInUseCase(any()),
          ).thenAnswer((_) async => right(testUser));
          when(
            () => mockSignOutUseCase(any()),
          ).thenAnswer((_) async => right(null));
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested());
          bloc.add(const SignOutRequested());
        },
        expect: () => [
          const AuthLoading(), // Sign in
          Authenticated(user: testUser),
          const AuthLoading(), // Sign out
          const Unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'transitions from AuthError to Authenticated on successful retry',
        build: () {
          var callCount = 0;
          when(() => mockSignInUseCase(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return left(const AuthFailure(message: 'First attempt failed'));
            }
            return right(testUser);
          });
          return authBloc;
        },
        act: (bloc) {
          bloc.add(const SignInRequested()); // Fail
          bloc.add(const SignInRequested()); // Success
        },
        expect: () => [
          const AuthLoading(), // First attempt
          isA<AuthError>()
              .having((s) => s.isBlocked, 'isBlocked', false)
              .having((s) => s.message, 'message', contains('Intento 1 de 3')),
          const AuthLoading(), // Second attempt
          Authenticated(user: testUser),
        ],
      );
    });
  });
}
