import 'package:fpdart/fpdart.dart';
import '../entities/product.dart';
import '../../core/errors/failures.dart';

/// Repositorio abstracto de productos del catálogo
///
/// Define las operaciones de consulta y sincronización del catálogo de productos
/// organizado por las tres categorías fijas: Comida, Bebidas y Postres.
/// Opera offline-first con Local_DB como fuente primaria de datos.
///
/// Validada por Requirement 5.1: Registro de Ventas con catálogo por categorías
/// Validada por Requirement 11.1: Catálogo de Productos Offline
/// Validada por Requirement 12.6: Configuración del catálogo por el Patrón
/// Validada por Requirement 13.2: Interfaces abstractas para repositorios
abstract class IProductRepository {
  /// Obtiene productos filtrados por categoría para un negocio
  ///
  /// Consulta los productos desde Local_DB primero (offline-first).
  /// Si hay conectividad y el catálogo local está vacío, intenta
  /// descargar desde el backend automáticamente.
  ///
  /// Parameters:
  /// - businessId: Identificador del negocio (aislamiento multi-tenant)
  /// - category: Categoría de productos a consultar (comida, bebidas, postres)
  ///
  /// Returns:
  /// - Right(List&lt;Product&gt;): Lista de productos activos de la categoría (puede estar vacía)
  /// - Left(LocalDatabaseFailure): Error al leer de la base de datos local
  /// - Left(NetworkFailure): Sin conectividad y catálogo local vacío
  ///
  /// Validada por Requirement 5.1: Mostrar categorías fijas en flujo de ventas
  /// Validada por Requirement 5.2: Recuperar productos con conectividad disponible
  /// Validada por Requirement 5.3: Recuperar productos sin conectividad desde Local_DB
  /// Validada por Requirement 11.1: Acceso al catálogo sin internet
  /// Validada por Requirement 15.2: Filtrado por business_id
  Future<Either<Failure, List<Product>>> getByCategory(
    String businessId,
    ProductCategory category,
  );

  /// Sincroniza el catálogo completo desde el backend
  ///
  /// Descarga todos los productos del negocio desde el backend REST
  /// y actualiza Local_DB. Opera con un timeout de 30 segundos.
  /// Los productos sin categoría asignada se clasifican como "Comida" por defecto.
  ///
  /// Parameters:
  /// - businessId: Identificador del negocio (aislamiento multi-tenant)
  ///
  /// Returns:
  /// - Right(void): Sincronización exitosa, catálogo actualizado en Local_DB
  /// - Left(NetworkFailure): Sin conectividad o timeout excedido
  /// - Left(ServerFailure): Error del backend (4xx/5xx)
  /// - Left(LocalDatabaseFailure): Error al escribir en Local_DB
  ///
  /// Validada por Requirement 11.2: Actualización del catálogo con conectividad
  /// Validada por Requirement 11.3: Clasificación por defecto como "Comida"
  /// Validada por Requirement 11.4: Conservar productos existentes si falla
  /// Validada por Requirement 11.5: Descarga automática al recuperar conectividad
  Future<Either<Failure, void>> syncCatalog(String businessId);
}
