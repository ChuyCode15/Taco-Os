import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';
import 'package:taco_os_app/domain/usecases/auth/sign_out_use_case.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  group('SignOutUseCase', () {
    test('should successfully sign out user', () async {
      // Arrange
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should return Failure when sign out fails', () async {
      // Arrange
      when(() => mockRepository.signOut()).thenAnswer(
        (_) async => Left(AuthFailure(message: 'Error al cerrar sesión')),
      );

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should call repository exactly once', () async {
      // Arrange
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await useCase(NoParams());

      // Assert
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
