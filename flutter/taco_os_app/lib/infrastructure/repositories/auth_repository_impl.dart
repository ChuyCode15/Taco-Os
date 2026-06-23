import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/secure_storage_service.dart';

/// Implementación concreta del repositorio de autenticación
///
/// Responsabilidades:
/// - Gestiona el flujo de Google Sign-In y obtención de JWT del backend
/// - Implementa lógica de bloqueo temporal tras 3 intentos fallidos
/// - Almacena y elimina el JWT usando SecureStorageService
/// - Valida y decodifica tokens JWT para obtener información del usuario
///
/// Nota: Usa Google Sign-In v7.0+ API con GoogleSignIn.instance
///
/// Validada por Requirements: 1.1, 1.2, 1.3, 1.5, 1.9
/// Validada por Requirement 13.2: Implementa interfaz abstracta
/// Validada por Requirement 13.5: Inyección de dependencias
class AuthRepositoryImpl implements IAuthRepository {
  final Dio _dio;
  final ISecureStorageService _secureStorage;
  final GoogleSignIn _googleSignIn;

  // Estado de intentos fallidos
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  AuthRepositoryImpl({
    Dio? dio,
    required ISecureStorageService secureStorage,
    required GoogleSignIn googleSignIn,
  }) : _dio = dio ?? Dio(),
       _secureStorage = secureStorage,
       _googleSignIn = googleSignIn;

  /// Inicia sesión con Google Sign-In y obtiene JWT del backend
  ///
  /// Flujo:
  /// 1. Verifica bloqueo por intentos fallidos
  /// 2. Inicia Google Sign-In con scopes requeridos
  /// 3. Obtiene idToken de Google
  /// 4. Envía token al backend para obtener JWT
  /// 5. Almacena JWT y retorna User
  ///
  /// Validada por Requirements: 1.1, 1.2, 1.3, 1.5
  @override
  Future<Either<Failure, User>> signInWithGoogle({
    bool isRegistration = false,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 INICIANDO GOOGLE SIGN-IN');
    print('   Tipo: ${isRegistration ? "REGISTRO" : "LOGIN"}');
    print('═══════════════════════════════════════════════════════════');

    try {
      // Requirement 1.5: Verificar bloqueo por intentos fallidos
      print('📋 Verificando bloqueo por intentos fallidos...');
      if (_isLocked()) {
        final remainingSeconds = _lockoutUntil!
            .difference(DateTime.now())
            .inSeconds;
        print('🚫 BLOQUEADO: $remainingSeconds segundos restantes');
        return left(
          AuthFailure(
            message:
                'Demasiados intentos fallidos. Intenta de nuevo en $remainingSeconds segundos.',
          ),
        );
      }
      print('✅ No hay bloqueo activo');

      // Requirement 1.1: Usar instancia inyectada de GoogleSignIn
      // La instancia ya está configurada con clientId en injection_container.dart
      print('📱 Usando instancia de GoogleSignIn inyectada...');
      print('✅ Instancia configurada con clientId Web');

      // Intentar autenticar con Google
      // Nota: signIn() muestra la UI de Google Sign-In
      GoogleSignInAccount? googleUser;

      try {
        print('🔐 Llamando a signIn() - mostrando UI de Google...');
        googleUser = await _googleSignIn.signIn();
        print('✅ signIn() completado');
        print('   Usuario obtenido: ${googleUser?.email ?? "NULL"}');
      } catch (e) {
        // Error durante la autenticación
        print('❌ ERROR en authenticate(): $e');
        print('   Tipo de error: ${e.runtimeType}');
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('cancel') ||
            errorString.contains('sign_in_cancelled') ||
            errorString.contains('sign_in_canceled')) {
          // Requirement 1.4: Usuario cancela el flujo
          print('i  El usuario canceló el flujo de autenticación');
          return left(
            const AuthCancelledFailure(message: 'Inicio de sesión cancelado'),
          );
        }
        _incrementFailedAttempts();
        print('!  Incrementando contador de fallos: $_failedAttempts/3');
        return left(AuthFailure(message: 'Error al iniciar sesión: $e'));
      }

      print('👤 Datos del usuario de Google:');
      print('   Email: ${googleUser!.email}');
      print('   Nombre: ${googleUser.displayName}');
      print('   ID: ${googleUser.id}');

      // Obtener la autenticación (idToken)
      // En v6.x, authentication es un Future
      print('🔑 Obteniendo authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      print(
        '   idToken: ${idToken != null ? "${idToken.substring(0, 20)}..." : "NULL"}',
      );

      if (idToken == null) {
        print('❌ ERROR: idToken es NULL');
        _incrementFailedAttempts();
        return left(
          const AuthFailure(message: 'No se pudo obtener el token de Google'),
        );
      }

      // Requirement 1.1 y 1.2: Enviar idToken al backend para obtener JWT
      final endpoint =
          '${ApiEndpoints.baseUrl}${ApiEndpoints.authGoogleSignIn}';
      print('');
      print('🌐 LLAMADA AL BACKEND:');
      print('   Endpoint: $endpoint');
      print(
        '   Payload: {google_token: "${idToken.substring(0, 20)}...", isRegistration: $isRegistration}',
      );

      final response = await _dio.post(
        endpoint,
        data: {'google_token': idToken, 'isRegistration': isRegistration},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📡 RESPUESTA DEL BACKEND:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.data}');

      // Manejar respuestas del servidor
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Respuesta exitosa del servidor');
        final data = response.data as Map<String, dynamic>;
        final String jwt = data['token'] ?? data['jwt'] ?? '';

        if (jwt.isEmpty) {
          print('❌ ERROR: JWT vacío en la respuesta');
          print('   Datos recibidos: $data');
          _incrementFailedAttempts();
          return left(
            const AuthFailure(
              message: 'El servidor no devolvió un token válido',
            ),
          );
        }

        print('🎟️  JWT recibido: ${jwt.substring(0, 20)}...');

        // Requirement 1.2: Almacenar JWT en almacenamiento seguro
        print('💾 Guardando JWT en almacenamiento seguro...');
        await _secureStorage.saveToken(jwt);
        print('✅ JWT guardado correctamente');

        // Crear usuario con datos de Google + backend
        final user = User(
          id: data['userId'] ?? data['id'] ?? '',
          email: googleUser.email,
          displayName: googleUser.displayName ?? '',
          role: (data['role']?.toString().toLowerCase() == 'patron')
              ? UserRole.patron
              : UserRole.cajero,
          businessId: data['businessId'],
          createdAt: DateTime.now(),
        );

        print('');
        print('✅ USUARIO CREADO:');
        print('   ID: ${user.id}');
        print('   Email: ${user.email}');
        print('   Nombre: ${user.displayName}');
        print('   Rol: ${user.role}');
        print('   Business ID: ${user.businessId}');

        // Reiniciar contador de intentos fallidos tras éxito
        _resetFailedAttempts();
        print('🔄 Contador de intentos reseteado');
        print('═══════════════════════════════════════════════════════════');
        print('🎉 AUTENTICACIÓN EXITOSA');
        print('═══════════════════════════════════════════════════════════');
        print('');

        return right(user);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('🚫 ERROR DE AUTENTICACIÓN:');
        print('   Status: ${response.statusCode}');
        print('   Mensaje: ${response.data}');
        _incrementFailedAttempts();
        return left(
          AuthFailure(
            message: response.data['message'] ?? 'Credenciales inválidas',
          ),
        );
      } else {
        print('!  ERROR DEL SERVIDOR:');
        print('   Status: ${response.statusCode}');
        print('   Mensaje: ${response.data}');
        _incrementFailedAttempts();
        return left(
          ServerFailure(
            statusCode: response.statusCode ?? 500,
            message: response.data['message'] ?? 'Error del servidor',
          ),
        );
      }
    } on TimeoutException catch (e) {
      print('');
      print('❌ TIMEOUT EXCEPTION:');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(TimeoutFailure(message: e.message));
    } on BackendUnavailableException catch (e) {
      print('');
      print('❌ BACKEND UNAVAILABLE EXCEPTION:');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(BackendUnavailableFailure(message: e.message));
    } on NetworkException catch (e) {
      print('');
      print('❌ NETWORK EXCEPTION:');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      print('');
      print('❌ SERVER EXCEPTION:');
      print('   Status: ${e.statusCode}');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on AuthException catch (e) {
      print('');
      print('❌ AUTH EXCEPTION:');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(AuthFailure(message: e.message));
    } on DioException catch (e) {
      print('');
      print('❌ DIO EXCEPTION (no capturada):');
      print('   Tipo: ${e.type}');
      print('   Mensaje: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      print('');
      _incrementFailedAttempts();
      return left(NetworkFailure(message: 'Error de conexión: ${e.message}'));
    } on LocalDatabaseException catch (e) {
      print('');
      print('❌ LOCAL DATABASE EXCEPTION:');
      print('   Mensaje: ${e.message}');
      print('');
      _incrementFailedAttempts();
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e, stackTrace) {
      print('');
      print('❌ EXCEPCIÓN INESPERADA:');
      print('   Tipo: ${e.runtimeType}');
      print('   Mensaje: $e');
      print('   Stack trace:');
      print(stackTrace);
      print('');
      _incrementFailedAttempts();
      return left(AuthFailure(message: 'Error inesperado: $e'));
    }
  }

  /// Cierra la sesión del usuario actual
  ///
  /// Requirement 1.9: Elimina JWT del almacenamiento seguro y limpia datos
  /// de identidad de la memoria.
  @override
  Future<Either<Failure, void>> signOut() async {
    print('');
    print('🚪 CERRANDO SESIÓN...');
    try {
      // Intentar cerrar sesión en el backend (best-effort, no bloqueante)
      final token = await _secureStorage.readToken();
      if (token != null) {
        print('📤 Notificando al backend...');
        try {
          await _dio.post(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.authSignOut}',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              validateStatus: (status) => true,
            ),
          );
          print('✅ Backend notificado');
        } catch (e) {
          print('!  Error notificando al backend (ignorado): $e');
        }
      }

      // Requirement 1.9: Eliminar JWT del almacenamiento seguro
      print('🗑️  Eliminando JWT del almacenamiento...');
      await _secureStorage.deleteToken();
      print('✅ JWT eliminado');

      // Cerrar sesión de Google Sign-In
      try {
        print('🔓 Cerrando sesión de Google...');
        await _googleSignIn.signOut();
        print('✅ Sesión de Google cerrada');
      } catch (e) {
        print('!  Error cerrando sesión de Google (ignorado): $e');
      }

      // Limpiar datos de identidad (contador de intentos)
      _resetFailedAttempts();
      print('🔄 Contador de intentos reseteado');
      print('✅ SESIÓN CERRADA EXITOSAMENTE');
      print('');

      return right(null);
    } on LocalDatabaseException catch (e) {
      print('❌ ERROR: $e');
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      print('❌ ERROR INESPERADO: $e');
      return left(AuthFailure(message: 'Error al cerrar sesión: $e'));
    }
  }

  /// Obtiene el usuario autenticado actual validando el JWT almacenado
  ///
  /// Requirement 1.6: Mantener sesión mientras JWT es válido
  /// Requirement 1.8: Invalidar sesión cuando JWT expira
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final token = await _secureStorage.readToken();

      if (token == null) {
        return right(null);
      }

      // Validar token con el backend
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.authMe}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = _decodeJwtToUser(token, data);
        return right(user);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expirado o inválido - Requirement 1.8
        await _secureStorage.deleteToken();
        return right(null);
      } else {
        return left(
          ServerFailure(
            statusCode: response.statusCode ?? 500,
            message: 'Error al validar sesión',
          ),
        );
      }
    } on TimeoutException catch (e) {
      return left(TimeoutFailure(message: e.message));
    } on BackendUnavailableException catch (e) {
      return left(BackendUnavailableFailure(message: e.message));
    } on NetworkException {
      // Sin conexión - la sesión local sigue siendo válida temporalmente
      return right(null);
    } on ServerException catch (e) {
      return left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on AuthException {
      // Token inválido o expirado
      await _secureStorage.deleteToken();
      return right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        // Sin conexión - asumir que la sesión local es válida temporalmente
        return right(null);
      }
      return left(NetworkFailure(message: 'Error de red: ${e.message}'));
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return left(AuthFailure(message: 'Error al obtener usuario: $e'));
    }
  }

  /// Vincula un Cajero al negocio mediante código QR
  ///
  /// Requirement 2.4: Vinculación mediante código QR del Patron
  @override
  Future<Either<Failure, void>> linkCajeroToBusiness(String qrCode) async {
    try {
      final token = await _secureStorage.readToken();

      if (token == null) {
        return left(const AuthFailure(message: 'No hay sesión activa'));
      }

      // Enviar código QR al backend para validación y vinculación
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.cashierLink('_')}',
        data: {'qrCode': qrCode},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(null);
      } else if (response.statusCode == 400) {
        return left(
          ValidationFailure(
            message:
                response.data['message'] ?? 'Código QR inválido o expirado',
          ),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return left(const AuthFailure(message: 'Sesión expirada'));
      } else {
        return left(
          ServerFailure(
            statusCode: response.statusCode ?? 500,
            message: 'Error al vincular al negocio',
          ),
        );
      }
    } on TimeoutException catch (e) {
      return left(TimeoutFailure(message: e.message));
    } on BackendUnavailableException catch (e) {
      return left(BackendUnavailableFailure(message: e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return left(const NetworkFailure(message: 'Sin conexión a internet'));
      }
      return left(NetworkFailure(message: 'Error de red: ${e.message}'));
    } catch (e) {
      return left(AuthFailure(message: 'Error al vincular: $e'));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────

  /// Verifica si hay un bloqueo activo por intentos fallidos
  ///
  /// Requirement 1.5: Bloqueo de 30 segundos tras 3 intentos fallidos
  bool _isLocked() {
    if (_lockoutUntil == null) return false;

    if (DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    } else {
      // Bloqueo expirado - reiniciar
      _lockoutUntil = null;
      _failedAttempts = 0;
      return false;
    }
  }

  /// Incrementa el contador de intentos fallidos
  ///
  /// Requirement 1.3: Máximo 3 intentos consecutivos
  /// Requirement 1.5: Bloquear por 30 segundos tras 3 intentos fallidos
  void _incrementFailedAttempts() {
    _failedAttempts++;

    if (_failedAttempts >= 3) {
      // Requirement 1.5: Bloquear por 30 segundos
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
    }
  }

  /// Reinicia el contador de intentos fallidos tras un login exitoso
  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  /// Decodifica el JWT y extrae información del usuario
  ///
  /// En una implementación real, esto usaría una librería como dart_jsonwebtoken
  /// para decodificar y validar el JWT completamente. Para este MVP,
  /// asumimos que el backend devuelve los datos del usuario en la respuesta.
  User _decodeJwtToUser(String jwt, Map<String, dynamic> data) {
    // Extraer información del usuario de la respuesta del backend
    final userId = data['userId'] ?? data['id'] ?? '';
    final email = data['email'] ?? '';
    final displayName = data['displayName'] ?? data['name'] ?? '';
    final roleString = data['role'] ?? 'cajero';
    final businessId = data['businessId'];

    // Parsear el rol
    final role = roleString.toLowerCase() == 'patron'
        ? UserRole.patron
        : UserRole.cajero;

    return User(
      id: userId,
      email: email,
      displayName: displayName,
      role: role,
      businessId: businessId,
      createdAt: DateTime.now(),
    );
  }
}
