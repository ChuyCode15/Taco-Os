import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';

/// Data source abstracta para sincronización de transacciones remotas
///
/// Define el contrato para la sincronización batch de transacciones
/// (ventas, gastos, cortes) con el backend REST.
///
/// Validada por Requirement 10.3: Sincronización batch cada 5 minutos
/// Validada por Requirement 15.4: Authorization header con JWT
/// Validada por Requirement 13.2: Dependencia de abstracciones
abstract class ITransactionRemoteDataSource {
  /// Sincroniza un lote de transacciones pendientes con el backend
  ///
  /// [token] JWT para autenticación
  /// [transactions] lista de transacciones en formato JSON (máximo 100)
  ///
  /// Retorna una lista de resultados indicando éxito/fallo por transacción
  ///
  /// Throws [NetworkException] si hay problemas de red
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<List<Map<String, dynamic>>> syncBatch(
    String token,
    List<Map<String, dynamic>> transactions,
  );
}

/// Implementación concreta de ITransactionRemoteDataSource
///
/// Usa dio para comunicación REST con el backend Spring Boot.
/// Implementa la lógica de sincronización batch descrita en el diseño.
///
/// Validada por Requirement 10.3: Sincronización batch cada 5 minutos
/// Validada por Requirement 10.8: Sync parcial marca solo las confirmadas
/// Validada por Requirement 15.4: Authorization: Bearer `<token>`
/// Validada por Requirement 13.5: Inyección de dependencias
class TransactionRemoteDataSourceImpl implements ITransactionRemoteDataSource {
  final Dio _dio;

  TransactionRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Map<String, dynamic>>> syncBatch(
    String token,
    List<Map<String, dynamic>> transactions,
  ) async {
    if (transactions.isEmpty) {
      return [];
    }

    // Validar tamaño del lote (Requirement 10.3: máximo 100 transacciones)
    if (transactions.length > 100) {
      throw ArgumentError(
        'El lote de sincronización no puede superar 100 transacciones. '
        'Recibido: ${transactions.length}',
      );
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.sync,
        data: {'transacciones': transactions},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results == null) {
          throw const ServerException(
            message: 'Respuesta del servidor no contiene el campo "results"',
            statusCode: 200,
          );
        }

        // Convertir los resultados a Map<String, dynamic>
        return results.map((result) => result as Map<String, dynamic>).toList();
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
        // Requirement 10.6: En error de red, reintentar en el próximo ciclo
        throw const NetworkException(message: 'Timeout de conexión');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Error de conexión: ${e.message}');
      } else if (e.response != null) {
        // Requirement 10.7: Error 4xx/5xx marca sync_error en DB
        final statusCode = e.response?.statusCode ?? 500;
        throw ServerException(
          message: 'Error del servidor: $statusCode - ${e.response?.data}',
          statusCode: statusCode,
        );
      } else {
        throw NetworkException(
          message: 'Error de red desconocido: ${e.message}',
        );
      }
    }
  }
}
