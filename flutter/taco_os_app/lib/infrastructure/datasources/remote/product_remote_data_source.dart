import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

/// Data source abstracta para obtener productos del backend
///
/// Define el contrato para la recuperación de productos por categoría
/// desde el backend REST.
///
/// Validada por Requirement 11.2: Descarga de catálogo con timeout de 30s
/// Validada por Requirement 15.4: Authorization header con JWT
/// Validada por Requirement 13.2: Dependencia de abstracciones
abstract class IProductRemoteDataSource {
  /// Obtiene los productos de una categoría desde el backend
  ///
  /// [token] JWT para autenticación
  /// [businessId] identificador del negocio (multi-tenant)
  /// [category] una de: 'comida', 'bebidas', 'postres'
  ///
  /// Retorna una lista de productos en formato JSON
  ///
  /// Throws [NetworkException] si hay problemas de red o timeout (30s)
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String token,
    String businessId,
    String category,
  );

  /// Sincroniza el catálogo completo del negocio
  ///
  /// [token] JWT para autenticación
  /// [businessId] identificador del negocio
  ///
  /// Retorna una lista de todos los productos del catálogo
  ///
  /// Throws [NetworkException] si hay problemas de red o timeout (30s)
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<List<Map<String, dynamic>>> syncCatalog(
    String token,
    String businessId,
  );
}

/// Implementación concreta de IProductRemoteDataSource
///
/// Usa dio para comunicación REST con el backend Spring Boot.
/// Implementa timeout de 30s según el diseño.
///
/// Validada por Requirement 11.2: Timeout de 30s en descarga de catálogo
/// Validada por Requirement 15.4: Authorization: Bearer `<token>`
/// Validada por Requirement 13.5: Inyección de dependencias
class ProductRemoteDataSourceImpl implements IProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String token,
    String businessId,
    String category,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.productsByCategory(businessId, category),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          // Requirement 11.2: Timeout de 30 segundos
          receiveTimeout: Duration(
            milliseconds: AppConstants.catalogSyncTimeoutMs,
          ),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>?;

        if (products == null) {
          // Respuesta válida pero sin productos
          return [];
        }

        return products
            .map((product) => product as Map<String, dynamic>)
            .toList();
      } else if (response.statusCode == 401) {
        throw const AuthException(message: 'Token JWT inválido o expirado');
      } else {
        throw ServerException(
          message: 'Respuesta inesperada del servidor: ${response.statusCode}',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Token JWT inválido o expirado');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Requirement 11.2: Si excede timeout, conservar productos existentes
        throw const NetworkException(
          message: 'Timeout de conexión al obtener productos (30s)',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Error de conexión: ${e.message}');
      } else if (e.response != null) {
        throw ServerException(
          message: 'Error del servidor: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          message: 'Error de red desconocido: ${e.message}',
        );
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncCatalog(
    String token,
    String businessId,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.catalogSync(businessId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          // Requirement 11.2: Timeout de 30 segundos
          receiveTimeout: Duration(
            milliseconds: AppConstants.catalogSyncTimeoutMs,
          ),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>?;

        if (products == null) {
          return [];
        }

        return products
            .map((product) => product as Map<String, dynamic>)
            .toList();
      } else if (response.statusCode == 401) {
        throw const AuthException(message: 'Token JWT inválido o expirado');
      } else {
        throw ServerException(
          message: 'Respuesta inesperada del servidor: ${response.statusCode}',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Token JWT inválido o expirado');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Requirement 11.2: Si falla o excede timeout, conservar existentes
        throw const NetworkException(
          message: 'Timeout de conexión al sincronizar catálogo (30s)',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Error de conexión: ${e.message}');
      } else if (e.response != null) {
        throw ServerException(
          message: 'Error del servidor: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          message: 'Error de red desconocido: ${e.message}',
        );
      }
    }
  }
}
