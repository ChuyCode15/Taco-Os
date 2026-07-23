import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';

/// Base abstract class for all use cases in the domain layer.
///
/// Every use case should extend this class and implement the [call] method.
/// This enforces a consistent contract across the application following
/// Clean Architecture principles.
///
/// **Type Parameters:**
/// - [ReturnType]: The success return type wrapped in Either
/// - [Params]: The input parameters required by the use case
///
/// **Returns:**
/// - `Future<Either<Failure, ReturnType>>`: A future that resolves to either
///   a [Failure] (Left) or the expected result [ReturnType] (Right)
///
/// **Example:**
/// ```dart
/// class RegisterSaleUseCase extends UseCase<Sale, RegisterSaleParams> {
///   final ITransactionRepository repository;
///
///   RegisterSaleUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, Sale>> call(RegisterSaleParams params) async {
///     // Validate params
///     // Call repository
///     // Return Either<Failure, Sale>
///   }
/// }
/// ```
///
/// **Validates: Requirements 13.1, 13.2**
abstract class UseCase<ReturnType, Params> {
  /// Executes the use case with the given [params].
  ///
  /// This method should contain:
  /// 1. Input validation (domain rules)
  /// 2. Calls to repository interfaces
  /// 3. Business logic orchestration
  /// 4. Error handling and mapping to [Failure] types
  Future<Either<Failure, ReturnType>> call(Params params);
}

/// Marker class for use cases that don't require parameters.
///
/// Use this when a use case doesn't need any input.
///
/// **Example:**
/// ```dart
/// class GetActiveSessionUseCase extends UseCase<CashSession?, NoParams> {
///   @override
///   Future<Either<Failure, CashSession?>> call(NoParams params) async {
///     // Implementation without parameters
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
