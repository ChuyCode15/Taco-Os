import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';

/// Parámetros para registrar una venta
class RegisterSaleParams {
  final Sale sale;

  const RegisterSaleParams({required this.sale});
}

/// Use case para registrar una venta
///
/// Valida los ítems y monto de la venta con Validators y delega
/// al ITransactionRepository para persistir en Local_DB.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Valida que la venta tenga al menos un ítem
/// 2. Valida que cada ítem tenga cantidad válida (1–999,999,999)
/// 3. Valida que el monto total sea positivo
/// 4. Invoca `ITransactionRepository.saveSale()` con los datos validados
/// 5. El repositorio registra la venta en Local_DB con is_synced = false
/// 6. Retorna la venta guardada al éxito
///
/// **Returns:**
/// - `Right(Sale)`: Venta registrada exitosamente
/// - `Left(ValidationFailure)`: Datos de la venta inválidos
/// - `Left(LocalDatabaseFailure)`: Error al escribir en SQLite
///
/// **Example:**
/// ```dart
/// final result = await registerSaleUseCase(
///   RegisterSaleParams(
///     sale: Sale(
///       id: 'sale-123',
///       sessionId: 'session-456',
///       businessId: 'biz-789',
///       cashierId: 'user-012',
///       items: [
///         SaleItem(
///           productId: 'prod-1',
///           productName: 'Taco al pastor',
///           quantity: 3,
///           unitPrice: 15.00,
///           subtotal: 45.00,
///         ),
///       ],
///       total: 45.00,
///       paymentMethod: PaymentMethod.cash,
///       status: SaleStatus.completed,
///       timestamp: DateTime.now(),
///     ),
///   ),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (sale) => print('Venta registrada: ${sale.id}'),
/// );
/// ```
class RegisterSaleUseCase extends UseCase<Sale, RegisterSaleParams> {
  final ITransactionRepository repository;

  RegisterSaleUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(RegisterSaleParams params) async {
    final sale = params.sale;

    // Validar que haya al menos un ítem
    if (sale.items.isEmpty) {
      return Left(
        ValidationFailure(message: 'La venta debe tener al menos un producto'),
      );
    }

    // Validar cada ítem de la venta
    for (final item in sale.items) {
      final quantityValidation = ProductQuantityValidator.validateValue(
        item.quantity,
      );
      if (!quantityValidation.isValid) {
        return Left(
          ValidationFailure(
            message:
                quantityValidation.errorMessage ??
                'Cantidad inválida para ${item.productName}',
          ),
        );
      }

      // Validar que el precio unitario sea positivo
      if (item.unitPrice <= 0) {
        return Left(
          ValidationFailure(
            message:
                'El precio unitario debe ser mayor a cero para ${item.productName}',
          ),
        );
      }

      // Validar que el subtotal coincida con cantidad × precio
      final expectedSubtotal = item.quantity * item.unitPrice;
      if ((item.subtotal - expectedSubtotal).abs() > 0.01) {
        return Left(
          ValidationFailure(
            message: 'Subtotal incorrecto para ${item.productName}',
          ),
        );
      }
    }

    // Validar que el total sea positivo
    if (sale.total <= 0) {
      return Left(
        ValidationFailure(message: 'El monto total debe ser mayor a cero'),
      );
    }

    // Validar que el total coincida con la suma de subtotales
    final expectedTotal = sale.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    if ((sale.total - expectedTotal).abs() > 0.01) {
      return Left(
        ValidationFailure(
          message: 'El total no coincide con la suma de los productos',
        ),
      );
    }

    // Delegar al repositorio para guardar la venta
    return await repository.saveSale(sale);
  }
}
