import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';

/// Parámetros para cancelar una venta
class CancelSaleParams {
  final String saleId;
  final String photoPath;
  final DateTime saleTimestamp;

  const CancelSaleParams({
    required this.saleId,
    required this.photoPath,
    required this.saleTimestamp,
  });
}

/// Use case para cancelar una venta dentro de la ventana anti-fraude
///
/// Valida la ventana anti-fraude (< 5 minutos) y la foto obligatoria,
/// luego delega al ITransactionRepository para marcar la venta como cancelada.
///
/// **Validates: Requirements 3.2, 5.6, 6.2, 7.2, 9.3, 9.4, 8.1**
///
/// **Flujo:**
/// 1. Valida que la venta esté dentro de la ventana anti-fraude (< 5 min)
/// 2. Valida que se haya proporcionado una foto obligatoria
/// 3. Invoca `ITransactionRepository.cancelSale()` con el ID y foto
/// 4. El repositorio marca la venta como cancelada y revierte totales
/// 5. Retorna la venta cancelada al éxito
///
/// **Returns:**
/// - `Right(Sale)`: Venta cancelada exitosamente
/// - `Left(ValidationFailure)`: Venta fuera de ventana anti-fraude o sin foto
/// - `Left(LocalDatabaseFailure)`: Error al actualizar SQLite
/// - `Left(CameraFailure)`: Cámara no disponible
///
/// **Example:**
/// ```dart
/// final result = await cancelSaleUseCase(
///   CancelSaleParams(
///     saleId: 'sale-123',
///     photoPath: '/path/to/cancellation-photo.jpg',
///     saleTimestamp: DateTime.now().subtract(Duration(minutes: 3)),
///   ),
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (sale) => print('Venta cancelada: ${sale.id}'),
/// );
/// ```
class CancelSaleUseCase extends UseCase<Sale, CancelSaleParams> {
  final ITransactionRepository repository;

  CancelSaleUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(CancelSaleParams params) async {
    // Validar ventana anti-fraude (< 5 minutos)
    final elapsed = DateTime.now().difference(params.saleTimestamp);
    if (elapsed.inMinutes >= 5) {
      return Left(
        ValidationFailure(
          message: 'La venta no puede ser cancelada después de 5 minutos',
        ),
      );
    }

    // Validar que se haya proporcionado la foto obligatoria
    if (params.photoPath.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'La foto del producto devuelto es obligatoria',
        ),
      );
    }

    // Delegar al repositorio para cancelar la venta
    return await repository.cancelSale(params.saleId, params.photoPath);
  }
}
