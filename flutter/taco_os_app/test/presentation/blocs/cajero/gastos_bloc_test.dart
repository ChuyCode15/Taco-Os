import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/expense.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_expense_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_state.dart';

// Mock classes
class MockRegisterExpenseUseCase extends Mock
    implements RegisterExpenseUseCase {}

// Fake classes for Mocktail
class FakeRegisterExpenseParams extends Fake implements RegisterExpenseParams {}

void main() {
  late GastosBloc gastosBloc;
  late MockRegisterExpenseUseCase mockRegisterExpenseUseCase;

  // Test fixtures
  final testExpense = Expense(
    id: 'test-expense-id',
    sessionId: 'test-session-id',
    businessId: 'test-business-id',
    cashierId: 'test-user-id',
    description: 'Compra de servilletas',
    amount: 50.0,
    timestamp: DateTime(2025, 1, 1, 10, 0),
    isSynced: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeRegisterExpenseParams());
  });

  setUp(() {
    mockRegisterExpenseUseCase = MockRegisterExpenseUseCase();

    gastosBloc = GastosBloc(registerExpenseUseCase: mockRegisterExpenseUseCase);
  });

  tearDown(() {
    gastosBloc.close();
  });

  group('GastosBloc', () {
    test('initial state is GastosInitial', () {
      expect(gastosBloc.state, const GastosInitial());
    });

    group('ExpenseFormChanged', () {
      blocTest<GastosBloc, GastosState>(
        'updates internal state but does not emit any state changes',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseFormChanged(
            description: 'Compra de hielo',
            amountInput: '25.50',
          ),
        ),
        expect: () => [],
        verify: (_) {
          // Verify internal state was updated (cannot directly test private fields)
          // This test confirms no state is emitted
        },
      );
    });

    group('ExpenseSubmitted', () {
      blocTest<GastosBloc, GastosState>(
        'emits [GastosLoading, GastosSuccess] when expense is registered successfully',
        build: () {
          when(
            () => mockRegisterExpenseUseCase(any()),
          ).thenAnswer((_) async => right(testExpense));
          return gastosBloc;
        },
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de servilletas',
            amountInput: '50.00',
          ),
        ),
        expect: () => [
          const GastosLoading(),
          GastosSuccess(expense: testExpense),
        ],
        verify: (_) {
          verify(() => mockRegisterExpenseUseCase(any())).called(1);
        },
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when description is empty',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: '',
            amountInput: '50.00',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'La descripción del gasto es requerida',
          ),
        ],
        verify: (_) {
          verifyNever(() => mockRegisterExpenseUseCase(any()));
        },
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when description is whitespace only',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: '   ',
            amountInput: '50.00',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'La descripción del gasto es requerida',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'truncates description to 100 characters when it exceeds the limit',
        build: () {
          when(
            () => mockRegisterExpenseUseCase(any()),
          ).thenAnswer((_) async => right(testExpense));
          return gastosBloc;
        },
        act: (bloc) => bloc.add(
          ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'A' * 150, // 150 characters
            amountInput: '50.00',
          ),
        ),
        expect: () => [
          const GastosLoading(),
          GastosSuccess(expense: testExpense),
        ],
        verify: (_) {
          // Verify the use case was called with truncated description
          final captured =
              verify(
                    () => mockRegisterExpenseUseCase(captureAny()),
                  ).captured.first
                  as RegisterExpenseParams;
          expect(captured.expense.description.length, 100);
        },
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when amount is empty',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'El monto del gasto es requerido',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when amount is zero',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '0.00',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'El monto debe ser mayor a cero',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when amount is negative',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '-25.00',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'El monto debe ser mayor a cero',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when amount exceeds 999,999.99',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '1000000.00',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: r'El monto no puede exceder $999,999.99',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosValidationError] when amount is not a valid number',
        build: () => gastosBloc,
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: 'abc',
          ),
        ),
        expect: () => [
          const GastosValidationError(
            message: 'El monto debe ser un valor numérico válido',
          ),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'emits [GastosLoading, GastosError] when database save fails',
        build: () {
          when(() => mockRegisterExpenseUseCase(any())).thenAnswer(
            (_) async => left(
              const LocalDatabaseFailure(
                message: 'Error al escribir en la base de datos',
              ),
            ),
          );
          return gastosBloc;
        },
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '25.00',
          ),
        ),
        expect: () => [
          const GastosLoading(),
          const GastosError(message: 'Error al escribir en la base de datos'),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'accepts valid amount at minimum boundary (0.01)',
        build: () {
          when(
            () => mockRegisterExpenseUseCase(any()),
          ).thenAnswer((_) async => right(testExpense));
          return gastosBloc;
        },
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '0.01',
          ),
        ),
        expect: () => [
          const GastosLoading(),
          GastosSuccess(expense: testExpense),
        ],
      );

      blocTest<GastosBloc, GastosState>(
        'accepts valid amount at maximum boundary (999,999.99)',
        build: () {
          when(
            () => mockRegisterExpenseUseCase(any()),
          ).thenAnswer((_) async => right(testExpense));
          return gastosBloc;
        },
        act: (bloc) => bloc.add(
          const ExpenseSubmitted(
            sessionId: 'test-session-id',
            businessId: 'test-business-id',
            cashierId: 'test-user-id',
            description: 'Compra de hielo',
            amountInput: '999999.99',
          ),
        ),
        expect: () => [
          const GastosLoading(),
          GastosSuccess(expense: testExpense),
        ],
      );
    });
  });
}
