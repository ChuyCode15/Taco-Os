import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_in_use_case.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    final tUser = User(
      id: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: UserRole.cajero,
      businessId: 'business-456',
      createdAt: DateTime(2024, 1, 1),
    );

    test('should return User when authentication is successful', () async {
      // Arrange
      when(
        () => mockRepository.signInWithGoogle(
          isRegistration: any(named: 'isRegistration'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(const SignInParams(isRegistration: false));

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should have returned a user'), (user) {
        expect(user, equals(tUser));
        expect(user.email, equals('test@example.com'));
        expect(user.role, equals(UserRole.cajero));
      });
      verify(
        () => mockRepository.signInWithGoogle(isRegistration: false),
      ).called(1);
    });

    test('should return AuthFailure when authentication fails', () async {
      // Arrange
      when(
        () => mockRepository.signInWithGoogle(
          isRegistration: any(named: 'isRegistration'),
        ),
      ).thenAnswer(
        (_) async => Left(AuthFailure(message: 'Autenticación fallida')),
      );

      // Act
      final result = await useCase(const SignInParams(isRegistration: false));

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect((failure as AuthFailure).message, contains('fallida'));
      }, (_) => fail('Should have returned a failure'));
      verify(
        () => mockRepository.signInWithGoogle(isRegistration: false),
      ).called(1);
    });

    test(
      'should return NetworkFailure when there is no connectivity',
      () async {
        // Arrange
        when(
          () => mockRepository.signInWithGoogle(
            isRegistration: any(named: 'isRegistration'),
          ),
        ).thenAnswer(
          (_) async => Left(NetworkFailure(message: 'Sin conectividad')),
        );

        // Act
        final result = await useCase(const SignInParams(isRegistration: false));

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<NetworkFailure>());
          expect((failure as NetworkFailure).message, contains('conectividad'));
        }, (_) => fail('Should have returned a failure'));
        verify(
          () => mockRepository.signInWithGoogle(isRegistration: false),
        ).called(1);
      },
    );

    test('should call repository exactly once', () async {
      // Arrange
      when(
        () => mockRepository.signInWithGoogle(
          isRegistration: any(named: 'isRegistration'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      // Act
      await useCase(const SignInParams(isRegistration: false));

      // Assert
      verify(
        () => mockRepository.signInWithGoogle(isRegistration: false),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
