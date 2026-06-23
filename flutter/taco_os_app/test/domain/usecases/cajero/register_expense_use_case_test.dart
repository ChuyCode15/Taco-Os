import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/expense.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_expense_use_case.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  late RegisterExpenseUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = RegisterExpenseUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Test expense',
        amount: 50.0,
        timestamp: DateTime.now(),
      ),
    );
  });

  group('RegisterExpenseUseCase - Boundary Value Testing for Amount', () {
    test('should fail with amount = 0.00 (minimum invalid)', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Compra de servilletas',
        amount: 0.00,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveExpense(any()));
    });

    test('should succeed with amount = 0.01 (minimum valid)', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Compra de servilletas',
        amount: 0.01,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);
      when(
        () => mockRepository.saveExpense(any()),
      ).thenAnswer((_) async => Right(expense));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveExpense(any())).called(1);
    });

    test('should succeed with amount = 999,999.99 (maximum valid)', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Compra mayor',
        amount: 999999.99,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);
      when(
        () => mockRepository.saveExpense(any()),
      ).thenAnswer((_) async => Right(expense));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveExpense(any())).called(1);
    });

    test('should fail with amount = 1,000,000 (exceeds maximum)', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Gasto muy grande',
        amount: 1000000.00,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);

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
      verifyNever(() => mockRepository.saveExpense(any()));
    });

    test('should fail with negative amount', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Gasto negativo',
        amount: -50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveExpense(any()));
    });
  });

  group('RegisterExpenseUseCase - Description Validation', () {
    test('should fail with empty description', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: '',
        amount: 50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, contains('requerida'));
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveExpense(any()));
    });

    test('should succeed with description of 1 character', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'A',
        amount: 50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);
      when(
        () => mockRepository.saveExpense(any()),
      ).thenAnswer((_) async => Right(expense));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveExpense(any())).called(1);
    });

    test('should succeed with description of exactly 100 characters', () async {
      // Arrange
      final description = 'A' * 100;
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: description,
        amount: 50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);
      when(
        () => mockRepository.saveExpense(any()),
      ).thenAnswer((_) async => Right(expense));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveExpense(any())).called(1);
    });

    test('should fail with description exceeding 100 characters', () async {
      // Arrange
      final description = 'A' * 101;
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: description,
        amount: 50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('100 caracteres'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveExpense(any()));
    });
  });

  group('RegisterExpenseUseCase - Repository Error Handling', () {
    test('should return LocalDatabaseFailure when repository fails', () async {
      // Arrange
      final expense = Expense(
        id: 'exp-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        description: 'Compra de servilletas',
        amount: 50.0,
        timestamp: DateTime.now(),
      );
      final params = RegisterExpenseParams(expense: expense);
      when(() => mockRepository.saveExpense(any())).thenAnswer(
        (_) async =>
            Left(LocalDatabaseFailure(message: 'Error escribiendo en SQLite')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.saveExpense(any())).called(1);
    });
  });
}
