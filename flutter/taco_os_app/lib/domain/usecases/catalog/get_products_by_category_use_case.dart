import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/repositories/i_product_repository.dart';

/// Parámetros para obtener productos por categoría
class GetProductsByCategoryParams {
  final String businessId;
  final ProductCategory category;

  const GetProductsByCategoryParams({
    required this.businessId,
    required this.category,
  });
}

/// Use case para obtener productos filtrados por categoría
///
/// Recupera los productos de una categoría específica desde la base de
/// datos local, operando en modo offline-first. El repositorio maneja
/// automáticamente la sincronización con el backend cuando hay conectividad.
///
/// **Validates: Requirements 5.1, 5.2, 5.3, 11.1**
///
/// **Sin validaciones de entrada** — businessId y category ya están validados
///
/// **Flujo:**
/// 1. Invoca `IProductRepository.getByCategory()`
/// 2. El repositorio consulta Local_DB primero (offline-first)
/// 3. Si hay conectividad y el catálogo está vacío, intenta sincronizar
/// 4. Retorna los productos de la categoría filtrados por business_id
///
/// **Comportamiento Offline-First:**
/// - Con conectividad: retorna desde Local_DB y sincroniza en background
/// - Sin conectividad: retorna desde Local_DB sin sincronizar
/// - Catálogo vacío sin red: retorna lista vacía con NetworkFailure
///
/// **Returns:**
/// - `Right(List<Product>)`: Lista de productos activos (puede estar vacía)
/// - `Left(LocalDatabaseFailure)`: Error al leer de la base de datos local
/// - `Left(NetworkFailure)`: Sin conectividad y catálogo local vacío
///
/// **Example:**
/// ```dart
/// final params = GetProductsByCategoryParams(
///   businessId: session.businessId,
///   category: ProductCategory.comida,
/// );
/// final result = await getProductsByCategoryUseCase(params);
/// result.fold(
///   (failure) => showError(failure.message),
///   (products) => displayProducts(products),
/// );
/// ```
class GetProductsByCategoryUseCase
    extends UseCase<List<Product>, GetProductsByCategoryParams> {
  final IProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
    GetProductsByCategoryParams params,
  ) async {
    // No requiere validación de entrada:
    // - businessId proviene de sesión activa verificada
    // - category es un enum con valores válidos garantizados

    // Invocar repositorio para obtener productos
    // El repositorio maneja:
    // - Consulta offline-first desde Local_DB (Requisito 5.3, 11.1)
    // - Sincronización automática con backend si hay conectividad (Requisito 5.2)
    // - Filtrado por business_id para aislamiento multi-tenant (Requisito 15.2)
    return await repository.getByCategory(params.businessId, params.category);
  }
}
