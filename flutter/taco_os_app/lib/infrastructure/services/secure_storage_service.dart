import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/errors/exceptions.dart';

/// Servicio abstracto para almacenamiento seguro de credenciales
///
/// Define el contrato para almacenar, leer y eliminar datos sensibles
/// como el JWT usando el almacenamiento seguro del sistema operativo.
///
/// Validada por Requirement 1.2: Almacenar token JWT en almacenamiento seguro local
/// Validada por Requirement 15.5: JWT exclusivamente en Keychain/Keystore
/// Validada por Requirement 13.2: Dependencia de abstracciones
abstract class ISecureStorageService {
  /// Guarda el JWT en almacenamiento seguro (Keychain/Keystore)
  ///
  /// [token] JWT a almacenar
  ///
  /// Throws [LocalDatabaseException] si falla la operación de escritura
  Future<void> saveToken(String token);

  /// Lee el JWT desde almacenamiento seguro
  ///
  /// Retorna el JWT almacenado o null si no existe
  ///
  /// Throws [LocalDatabaseException] si falla la operación de lectura
  Future<String?> readToken();

  /// Elimina el JWT del almacenamiento seguro
  ///
  /// Requirement 1.9: Al cerrar sesión, eliminar JWT del almacenamiento seguro
  ///
  /// Throws [LocalDatabaseException] si falla la operación de eliminación
  Future<void> deleteToken();

  /// Verifica si existe un JWT almacenado
  ///
  /// Retorna true si existe un JWT, false en caso contrario
  Future<bool> hasToken();
}

/// Implementación concreta de ISecureStorageService
///
/// Usa flutter_secure_storage para almacenar el JWT en:
/// - iOS: Keychain
/// - Android: Keystore
///
/// NUNCA persiste el JWT en SQLite ni en SharedPreferences (Requirement 15.5)
///
/// Validada por Requirement 1.2: Almacenar token JWT tras autenticación exitosa
/// Validada por Requirement 1.9: Eliminar JWT al cerrar sesión
/// Validada por Requirement 15.5: JWT exclusivamente en Keychain/Keystore
/// Validada por Requirement 13.5: Inyección de dependencias
class SecureStorageServiceImpl implements ISecureStorageService {
  final FlutterSecureStorage _storage;

  // Clave constante para almacenar el JWT
  static const String _jwtKey = 'jwt';

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    try {
      // Requirement 1.2 y 15.5: Guardar JWT en almacenamiento seguro
      // (Keychain en iOS, Keystore en Android)
      await _storage.write(key: _jwtKey, value: token);
    } catch (e) {
      throw LocalDatabaseException(
        message: 'Error al guardar el token JWT: $e',
      );
    }
  }

  @override
  Future<String?> readToken() async {
    try {
      // Leer JWT desde almacenamiento seguro
      final token = await _storage.read(key: _jwtKey);
      return token;
    } catch (e) {
      throw LocalDatabaseException(message: 'Error al leer el token JWT: $e');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      // Requirement 1.9: Eliminar JWT al cerrar sesión
      await _storage.delete(key: _jwtKey);
    } catch (e) {
      throw LocalDatabaseException(
        message: 'Error al eliminar el token JWT: $e',
      );
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _jwtKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      // Si hay error al leer, asumimos que no hay token
      return false;
    }
  }
}
