import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

/// Repositorio abstracto de autenticación y autorización
///
/// Define las operaciones de autenticación, gestión de sesión y vinculación
/// de cajeros al negocio. Todas las implementaciones concretas deben retornar
/// Either<Failure, Type> para manejar errores de forma funcional.
///
/// Validada por Requirement 1.1: Autenticación con Google Sign-In
/// Validada por Requirement 1.2: Almacenamiento seguro del token JWT
/// Validada por Requirement 1.9: Cierre de sesión
/// Validada por Requirement 2.4: Vinculación de Cajero mediante código QR
/// Validada por Requirement 13.2: Interfaces abstractas para repositorios
abstract class IAuthRepository {
  /// Inicia sesión con Google Sign-In
  ///
  /// Inicia el flujo de autenticación de Google Sign-In y, si es exitoso,
  /// almacena el token JWT en almacenamiento seguro.
  ///
  /// Parameters:
  /// - isRegistration: Flag que indica si el usuario se está registrando (true)
  ///   o iniciando sesión (false). Este parámetro se envía al backend para
  ///   determinar el flujo de autenticación apropiado.
  ///
  /// Returns:
  /// - Right(User): Usuario autenticado con información de perfil y rol
  /// - Left(AuthFailure): Si la autenticación falla o el usuario cancela
  /// - Left(NetworkFailure): Si no hay conectividad
  ///
  /// Validada por Requirement 1.1: Flujo de autenticación con Google
  /// Validada por Requirement 1.2: Almacenamiento del token JWT
  Future<Either<Failure, User>> signInWithGoogle({bool isRegistration = false});

  /// Cierra la sesión del usuario actual
  ///
  /// Elimina el token JWT del almacenamiento seguro y borra los datos de
  /// identidad y rol del usuario de la memoria de la aplicación.
  ///
  /// Returns:
  /// - Right(void): Sesión cerrada exitosamente
  /// - Left(Failure): Error al cerrar sesión (raramente ocurre)
  ///
  /// Validada por Requirement 1.9: Cierre de sesión y limpieza de datos
  Future<Either<Failure, void>> signOut();

  /// Obtiene el usuario autenticado actual
  ///
  /// Verifica el token JWT almacenado y retorna el usuario si la sesión
  /// es válida. Retorna null si no hay sesión activa o el token expiró.
  ///
  /// Returns:
  /// - Right(User): Usuario autenticado con sesión válida
  /// - Right(null): No hay sesión activa o el token expiró
  /// - Left(AuthFailure): Error al validar el token
  ///
  /// Validada por Requirement 1.6: Mantener sesión mientras JWT es válido
  /// Validada por Requirement 1.8: Invalidar sesión cuando JWT expira
  Future<Either<Failure, User?>> getCurrentUser();

  /// Vincula un Cajero al negocio mediante código QR
  ///
  /// Lee el código QR escaneado, valida que sea vigente (< 24 horas) y
  /// asocia al Cajero actual con el business_id correspondiente.
  ///
  /// Parameters:
  /// - qrCode: Contenido del código QR escaneado
  ///
  /// Returns:
  /// - Right(void): Vinculación exitosa, business_id almacenado
  /// - Left(ValidationFailure): Código QR inválido o expirado
  /// - Left(NetworkFailure): Sin conectividad para validar el código
  /// - Left(ServerFailure): Error del backend al validar el QR
  ///
  /// Validada por Requirement 2.4: Vinculación mediante código QR del Patron
  /// Validada por Requirement 13.2: Separación de responsabilidades
  Future<Either<Failure, void>> linkCajeroToBusiness(String qrCode);
}
