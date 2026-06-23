import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/repositories/i_session_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/open_session_use_case.dart';

class MockSessionRepository extends Mock implements ISessionRepository {}

void main() {
  late OpenSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = OpenSessionUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const OpenSessionParams(
        businessId: 'business-123',
        userId: 'user-456',
        initialCash: 100.0,
      ),
    );
  });

  group('OpenSessionUseCase - Boundary Value Testing', () {
    final tSession = CashSession(
      id: 'session-123',
      businessId: 'business-123',
      userId: 'user-456',
      initialCash: 100.0,
      status: SessionStatus.open,
      openedAt: DateTime.now(),
    );

    test('should succeed with initialCash = 0.00 (minimum valid)', () async {
      // Arrange
      const params = OpenSessionUseCaseParams(
        businessId: 'business-123',
        userId: 'user-456',
        initialCash: 0.00,
      );
      when(
        () => mockRepository.openSession(any()),
      ).thenAnswer((_) async => Right(tSession.copyWith(initialCash: 0.00)));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.openSession(any())).called(1);
    });

    test(
      'should succeed with initialCash = 0.01 (just above minimum)',
      () async {
        // Arrange
        const params = OpenSessionUseCaseParams(
          businessId: 'business-123',
          userId: 'user-456',
          initialCash: 0.01,
        );
        when(
          () => mockRepository.openSession(any()),
        ).thenAnswer((_) async => Right(tSession.copyWith(initialCash: 0.01)));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.openSession(any())).called(1);
      },
    );

    test(
      'should succeed with initialCash = 999,999.99 (maximum valid)',
      () async {
        // Arrange
        const params = OpenSessionUseCaseParams(
          businessId: 'business-123',
          userId: 'user-456',
          initialCash: 999999.99,
        );
        when(() => mockRepository.openSession(any())).thenAnswer(
          (_) async => Right(tSession.copyWith(initialCash: 999999.99)),
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.openSession(any())).called(1);
      },
    );

    test(
      'should fail with initialCash = 1,000,000 (exceeds maximum)',
      () async {
        // Arrange
        const params = OpenSessionUseCaseParams(
          businessId: 'business-123',
          userId: 'user-456',
          initialCash: 1000000.00,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('no puede exceder'),
          );
        }, (_) => fail('Should have returned a failure'));
        verifyNever(() => mockRepository.openSession(any()));
      },
    );

    test('should fail with negative initialCash', () async {
      // Arrange
      const params = OpenSessionUseCaseParams(
        businessId: 'business-123',
        userId: 'user-456',
        initialCash: -100.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('no puede ser negativo'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.openSession(any()));
    });

    test('should succeed with typical mid-range value', () async {
      // Arrange
      const params = OpenSessionUseCaseParams(
        businessId: 'business-123',
        userId: 'user-456',
        initialCash: 500.00,
      );
      when(
        () => mockRepository.openSession(any()),
      ).thenAnswer((_) async => Right(tSession.copyWith(initialCash: 500.0)));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.openSession(any())).called(1);
    });
  });

  group('OpenSessionUseCase - Repository Error Handling', () {
    test('should return LocalDatabaseFailure when repository fails', () async {
      // Arrange
      const params = OpenSessionUseCaseParams(
        businessId: 'business-123',
        userId: 'user-456',
        initialCash: 500.0,
      );
      when(() => mockRepository.openSession(any())).thenAnswer(
        (_) async =>
            Left(LocalDatabaseFailure(message: 'Error escribiendo en SQLite')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect((failure as LocalDatabaseFailure).message, contains('SQLite'));
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.openSession(any())).called(1);
    });
  });
}
