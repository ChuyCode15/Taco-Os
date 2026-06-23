import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';

/// Data source abstracta para operaciones de autenticación remotas
///
/// Define el contrato para la autenticación con Google y el backend.
///
/// Validada por Requirement 1.1: Autenticación con Google Sign-In
/// Validada por Requirement 13.2: Dependencia de abstracciones
abstract class IAuthRemoteDataSource {
  /// Inicia el flujo de Google Sign-In y obtiene el JWT del backend
  ///
  /// Throws [AuthException] si falla la autenticación
  /// Throws [NetworkException] si hay problemas de red
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<Map<String, dynamic>> signInWithGoogle();

  /// Cierra la sesión invalidando el JWT en el backend
  ///
  /// Requiere [token] JWT válido
  /// Throws [NetworkException] si hay problemas de red
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<void> signOut(String token);

  /// Valida el JWT actual y obtiene el perfil del usuario
  ///
  /// Requiere [token] JWT válido
  /// Throws [AuthException] si el token es inválido o ha expirado
  /// Throws [NetworkException] si hay problemas de red
  /// Throws [ServerException] si el backend retorna 4xx/5xx
  Future<Map<String, dynamic>> getCurrentUser(String token);
}

/// Implementación concreta de IAuthRemoteDataSource
///
/// Usa google_sign_in para autenticación OAuth2 y dio para comunicación REST.
///
/// Validada por Requirement 1.1: Autenticación con Google Sign-In
/// Validada por Requirement 13.5: Inyección de dependencias
class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required GoogleSignIn googleSignIn,
  }) : _dio = dio,
       _googleSignIn = googleSignIn;

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Paso 1: Autenticación con Google (v6.x usa signIn())
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          message: 'Inicio de sesión cancelado por el usuario',
        );
      }

      // Paso 2: Obtener el token de Google (authentication es Future en v6.x)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthException(
          message: 'No se pudo obtener el token de Google',
        );
      }

      // Paso 3: Intercambiar el token de Google por un JWT del backend
      final response = await _dio.post(
        ApiEndpoints.authGoogleSignIn,
        data: {'googleIdToken': idToken},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: 'Respuesta inesperada del servidor: ${response.statusCode}',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      // Distinguir entre diferentes tipos de errores de red
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const TimeoutException(
          message: 'La conexión está tardando demasiado. Intenta de nuevo.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        // Verificar si es problema de red o backend no disponible
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('failed host lookup') ||
            errorMessage.contains('network is unreachable') ||
            errorMessage.contains('no address associated') ||
            errorMessage.contains('software caused connection abort')) {
          throw const NetworkException(
            message: 'Sin conexión a internet. Verifica tu conexión.',
          );
        } else {
          // Backend no responde pero hay internet
          throw const BackendUnavailableException(
            message:
                'No se puede conectar con el servidor. Verifica que el backend esté activo.',
          );
        }
      } else if (e.response != null) {
        // El servidor respondió pero con error
        final statusCode = e.response?.statusCode ?? 500;
        final responseMessage =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Error del servidor';
        throw ServerException(message: responseMessage, statusCode: statusCode);
      } else {
        // Error desconocido, probablemente de red
        throw const NetworkException(
          message: 'Error de conexión inesperado. Verifica tu internet.',
        );
      }
    } on PlatformException catch (e) {
      // Handle Google Sign-In exceptions en v6.x (Requirement 1.4)
      throw AuthException(
        message: 'Google Sign-In falló: ${e.code} - ${e.message}',
      );
    } catch (e) {
      if (e is AuthException || e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw AuthException(
        message: 'Error inesperado durante la autenticación: $e',
      );
    }
  }

  @override
  Future<void> signOut(String token) async {
    try {
      // Paso 1: Invalidar el JWT en el backend
      await _dio.post(
        ApiEndpoints.authSignOut,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Paso 2: Cerrar sesión de Google
      await _googleSignIn.signOut();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const TimeoutException(
          message: 'La conexión está tardando demasiado. Intenta de nuevo.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('failed host lookup') ||
            errorMessage.contains('network is unreachable') ||
            errorMessage.contains('no address associated') ||
            errorMessage.contains('software caused connection abort')) {
          throw const NetworkException(
            message: 'Sin conexión a internet. Verifica tu conexión.',
          );
        } else {
          throw const BackendUnavailableException(
            message:
                'No se puede conectar con el servidor. Verifica que el backend esté activo.',
          );
        }
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
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.authMe,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
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
        throw const TimeoutException(
          message: 'La conexión está tardando demasiado. Intenta de nuevo.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('failed host lookup') ||
            errorMessage.contains('network is unreachable') ||
            errorMessage.contains('no address associated') ||
            errorMessage.contains('software caused connection abort')) {
          throw const NetworkException(
            message: 'Sin conexión a internet. Verifica tu conexión.',
          );
        } else {
          throw const BackendUnavailableException(
            message:
                'No se puede conectar con el servidor. Verifica que el backend esté activo.',
          );
        }
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
