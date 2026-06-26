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

      // Paso 2: Backend 2-step auth: verificar → registrar
      final idGoogle = googleUser.id;

      // Paso 2a: Verificar si el usuario ya existe
      final verificarResponse = await _dio.get(
        ApiEndpoints.authVerificar(idGoogle),
      );

      final verificarData = verificarResponse.data as Map<String, dynamic>;
      if (verificarData['existe'] == true) {
        // Usuario existe: retorna JWT directamente
        return verificarData;
      }

      // Paso 2b: Usuario nuevo: registrar con datos de Google
      final registrarResponse = await _dio.post(
        ApiEndpoints.authRegistrar,
        data: {
          'idGoogle': idGoogle,
          'nickname': googleUser.displayName ?? 'Usuario',
          'correo': googleUser.email,
          'numero': null,
          'rol': 'dueño',
        },
      );

      if (registrarResponse.statusCode == 200 &&
          registrarResponse.data is Map) {
        return registrarResponse.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message:
              'Respuesta inesperada del servidor: ${registrarResponse.statusCode}',
          statusCode: registrarResponse.statusCode ?? 500,
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
    // Logout es operación client-side. JWTs son stateless, no hay
    // sesión de servidor que invalidar. Solo cerramos Google.
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignorar errores de Google Sign-In en logout
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    // Backend no tiene endpoint /auth/me. getCurrentUser() decodifica
    // el JWT localmente (estándar: Google, Facebook, AWS lo hacen).
    // Este método ya no se usa — ver auth_repository_impl.dart.
    throw UnimplementedError(
      'getCurrentUser se ejecuta localmente via JWT decode',
    );
  }
}
