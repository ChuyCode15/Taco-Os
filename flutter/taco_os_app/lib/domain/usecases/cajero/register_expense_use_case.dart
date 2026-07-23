import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/domain/entities/expense.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';

/// Parámetros para registrar un gasto
class RegisterExpenseParams {
  final Expense expense;

  const RegisterExpenseParams({required this.expense});
}

/// Use case para registrar un gasto del turno
///
/// Valida la descripción y monto del gasto con Validators y delega
/// al ITransactionRepository para persistir en Local_DB.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Valida la descripción (no vacía, máximo 100 caracteres)
/// 2. Valida el monto (0.01–999,999.99)
/// 3. Invoca `ITransactionRepository.saveExpense()` con los datos validados
/// 4. El repositorio registra el gasto en Local_DB con is_synced = false
/// 5. Retorna el gasto guardado al éxito
///
/// **Returns:**
/// - `Right(Expense)`: Gasto registrado exitosamente
/// - `Left(ValidationFailure)`: Datos del gasto inválidos
/// - `Left(LocalDatabaseFailure)`: Error al escribir en SQLite
///
/// **Example:**
/// ```dart
/// final result = await registerExpenseUseCase(
///   RegisterExpenseParams(
///     expense: Expense(
///       id: 'exp-123',
///       sessionId: 'session-456',
///       businessId: 'biz-789',
///       cashierId: 'user-012',
///       description: 'Compra de servilletas',
///       amount: 50.00,
///       timestamp: DateTime.now(),
///     ),
///   ),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (expense) => print('Gasto registrado: ${expense.id}'),
/// );
/// ```
class RegisterExpenseUseCase extends UseCase<Expense, RegisterExpenseParams> {
  final ITransactionRepository repository;

  RegisterExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(RegisterExpenseParams params) async {
    final expense = params.expense;

    // Validar descripción usando Validators
    final descriptionValidation = ExpenseDescriptionValidator.validate(
      expense.description,
    );
    if (!descriptionValidation.isValid) {
      return Left(
        ValidationFailure(
          message: descriptionValidation.errorMessage ?? 'Descripción inválida',
        ),
      );
    }

    // Validar monto usando Validators
    final amountValidation = ExpenseAmountValidator.validateValue(
      expense.amount,
    );
    if (!amountValidation.isValid) {
      return Left(
        ValidationFailure(
          message: amountValidation.errorMessage ?? 'Monto inválido',
        ),
      );
    }

    // Delegar al repositorio para guardar el gasto
    return await repository.saveExpense(expense);
  }
}
