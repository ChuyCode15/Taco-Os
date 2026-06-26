import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/secure_storage_service.dart';

/// Implementación concreta del repositorio de autenticación
///
/// Flujo de login (alineado con backend Spring Boot):
/// 1. Google Sign-In → obtiene idGoogle, email, displayName
/// 2. GET /auth/verificar/{idGoogle} → backend verifica si existe
/// 3. Si existe (200): retorna JWT + datos → va al dashboard
/// 4. Si no existe (404): retorna AuthResult(existe: false) → va a registro
///
/// Flujo de registro:
/// 1. POST /auth/registrar con { idGoogle, nickname, correo, numero, rol }
/// 2. Backend retorna JWT + datos del usuario
///
/// getCurrentUser() decodifica el JWT localmente (sin GET /auth/me).
class AuthRepositoryImpl implements IAuthRepository {
  final Dio _dio;
  final ISecureStorageService _secureStorage;
  final GoogleSignIn _googleSignIn;

  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  AuthRepositoryImpl({
    Dio? dio,
    required ISecureStorageService secureStorage,
    required GoogleSignIn googleSignIn,
  }) : _dio = dio ?? Dio(),
       _secureStorage = secureStorage,
       _googleSignIn = googleSignIn;

  // ── Login flow: Google → Verify → Route ───────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> signInWithGoogleOnly() async {
    try {
      if (_isLocked()) {
        final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
        return left(AuthFailure(
          message: 'Demasiados intentos fallidos. Intenta de nuevo en $remaining segundos.',
        ));
      }

      GoogleSignInAccount? googleUser;
      try {
        debugPrint('[Auth] Calling GoogleSignIn.signIn()...');
        googleUser = await _googleSignIn.signIn();
        debugPrint('[Auth] GoogleSignIn result: ${googleUser != null ? googleUser.email : 'null'}');
      } catch (e) {
        debugPrint('[Auth] GoogleSignIn error: $e');
        final err = e.toString().toLowerCase();
        if (err.contains('cancel') || err.contains('sign_in_cancelled') || err.contains('sign_in_canceled')) {
          return left(const AuthCancelledFailure(message: 'Inicio de sesión cancelado'));
        }
        _incrementFailedAttempts();
        return left(AuthFailure(message: 'Error al iniciar sesión con Google: $e'));
      }

      if (googleUser == null) {
        debugPrint('[Auth] GoogleSignIn returned null — possible causes: no Google account on device, SHA-1 not registered in Google Cloud Console, or Google Play Services issue');
        return left(const AuthFailure(
          message: 'No se pudo conectar con Google. Verifica que tengas una cuenta de Google configurada en el dispositivo.',
        ));
      }

      return right({
        'idGoogle': googleUser.id,
        'email': googleUser.email,
        'displayName': googleUser.displayName ?? '',
      });
    } catch (e) {
      _incrementFailedAttempts();
      return left(AuthFailure(message: 'Error inesperado al obtener credenciales de Google: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyUser(String idGoogle) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authVerificar(idGoogle)}';

      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final existe = data['existe'] as bool? ?? false;

        if (existe) {
          _resetFailedAttempts();
          return right(AuthResult(
            existe: true,
            token: data['token'] as String?,
            usuario: data['usuario'] as Map<String, dynamic>?,
          ));
        }
      }

      // 404 o 200 con existe=false → usuario nuevo
      _resetFailedAttempts();
      return right(const AuthResult(existe: false));
    } on DioException catch (e) {
      _incrementFailedAttempts();
      return left(_handleDioError(e));
    } catch (e) {
      _incrementFailedAttempts();
      return left(AuthFailure(message: 'Error al verificar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> registerUser({
    required String idGoogle,
    required String nickname,
    required String email,
    String? phone,
    required String role,
  }) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authRegistrar}';

      final response = await _dio.post(
        url,
        data: {
          'idGoogle': idGoogle,
          'nickname': nickname,
          'correo': email,
          'numero': phone,
          'rol': role,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        _resetFailedAttempts();
        return right(AuthResult(
          existe: true,
          token: data['token'] as String?,
          usuario: data['usuario'] as Map<String, dynamic>?,
        ));
      }

      _incrementFailedAttempts();
      return left(ServerFailure(
        statusCode: response.statusCode ?? 500,
        message: response.data['message'] ?? 'Error al registrar usuario',
      ));
    } on DioException catch (e) {
      _incrementFailedAttempts();
      return left(_handleDioError(e));
    } catch (e) {
      _incrementFailedAttempts();
      return left(AuthFailure(message: 'Error inesperado al registrar: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> storeTokenAndParseUser({
    required String token,
    required String fallbackEmail,
    required String fallbackDisplayName,
  }) async {
    try {
      if (token.isEmpty) {
        return left(const AuthFailure(message: 'El servidor no devolvió un token válido'));
      }
      await _secureStorage.saveToken(token);
      final user = _decodeJwt(token) ?? _fallbackUser(fallbackEmail, fallbackDisplayName);
      return right(user);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return left(AuthFailure(message: 'Error al almacenar token: $e'));
    }
  }

  // ── Full flow (legacy, used by SignInUseCase) ─────────────────────────────

  @override
  Future<Either<Failure, User>> signInWithGoogle({bool isRegistration = false}) async {
    final googleResult = await signInWithGoogleOnly();
    return googleResult.fold(
      (failure) => left(failure),
      (googleData) async {
        final idGoogle = googleData['idGoogle'] as String;
        final email = googleData['email'] as String;
        final displayName = googleData['displayName'] as String;

        final verifyResult = await verifyUser(idGoogle);
        return verifyResult.fold(
          (failure) => left(failure),
          (authResult) async {
            if (authResult.existe && authResult.token != null) {
              return storeTokenAndParseUser(
                token: authResult.token!,
                fallbackEmail: email,
                fallbackDisplayName: displayName,
              );
            }

            // No existe → registrar
            final regResult = await registerUser(
              idGoogle: idGoogle,
              nickname: displayName,
              email: email,
              role: isRegistration ? 'dueño' : 'cajero',
            );
            return regResult.fold(
              (failure) => left(failure),
              (regAuth) {
                if (regAuth.token != null) {
                  return storeTokenAndParseUser(
                    token: regAuth.token!,
                    fallbackEmail: email,
                    fallbackDisplayName: displayName,
                  );
                }
                return left(const AuthFailure(message: 'No se pudo registrar el usuario'));
              },
            );
          },
        );
      },
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _secureStorage.deleteToken();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      _resetFailedAttempts();
      return right(null);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return left(AuthFailure(message: 'Error al cerrar sesión: $e'));
    }
  }

  // ── Get current user ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final token = await _secureStorage.readToken();
      if (token == null) return right(null);
      final user = _decodeJwt(token);
      if (user == null) {
        await _secureStorage.deleteToken();
        return right(null);
      }
      return right(user);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return left(AuthFailure(message: 'Error al obtener usuario: $e'));
    }
  }

  // ── Link cajero ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> linkCajeroToBusiness(String qrCode) async {
    try {
      final token = await _secureStorage.readToken();
      if (token == null) {
        return left(const AuthFailure(message: 'No hay sesión activa'));
      }

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.businessLink}',
        data: {'codigo': qrCode, 'usuarioId': _decodeJwt(token)?.id},
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
        return left(ValidationFailure(
          message: response.data['message'] ?? 'Código QR inválido o expirado',
        ));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return left(const AuthFailure(message: 'Sesión expirada'));
      } else {
        return left(ServerFailure(
          statusCode: response.statusCode ?? 500,
          message: 'Error al vincular al negocio',
        ));
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
      return left(NetworkFailure(message: 'Error de red: ${e.message}'));
    } catch (e) {
      return left(AuthFailure(message: 'Error al vincular: $e'));
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  bool _isLocked() {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isBefore(_lockoutUntil!)) return true;
    _lockoutUntil = null;
    _failedAttempts = 0;
    return false;
  }

  void _incrementFailedAttempts() {
    _failedAttempts++;
    if (_failedAttempts >= 3) {
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
    }
  }

  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  /// Mapea errores de Dio a Failures del dominio
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    } else if (e.type == DioExceptionType.connectionError) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('failed host lookup') || msg.contains('network is unreachable')) {
        return const NetworkFailure(message: 'Sin conexión a internet. Verifica tu conexión.');
      }
      return const BackendUnavailableFailure();
    } else if (e.response != null) {
      return ServerFailure(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? 'Error del servidor',
      );
    }
    return NetworkFailure(message: 'Error de conexión: ${e.message}');
  }

  User _fallbackUser(String email, String displayName) {
    return User(
      id: '',
      email: email,
      displayName: displayName,
      role: UserRole.cajero,
      createdAt: DateTime.now(),
    );
  }

  /// Decodifica un JWT localmente sin llamada al servidor
  User? _decodeJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = data['exp'] as int?;
      if (exp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        if (DateTime.now().isAfter(expiryDate)) return null;
      }

      final userId = data['sub'] as String? ?? '';
      final rol = data['rol'] as String? ?? 'cajero';
      final nickname = data['nickname'] as String? ?? '';
      final role = rol.toLowerCase() == 'dueño' ? UserRole.dueno : UserRole.cajero;

      return User(
        id: userId,
        email: '',
        displayName: nickname,
        role: role,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}
