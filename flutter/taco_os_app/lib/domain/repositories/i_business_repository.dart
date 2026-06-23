import 'package:fpdart/fpdart.dart';
import '../entities/business.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

/// Repositorio abstracto de gestión de negocios y cajeros
///
/// Define las operaciones de creación de negocios, vinculación de cajeros
/// y consultas relacionadas con la gestión del patrón.
///
/// Validada por Requirement 14.1: Límites de negocios según plan
/// Validada por Requirement 14.2: Límites de cajeros según plan
/// Validada por Requirement 13.2: Interfaces abstractas para repositorios
abstract class IBusinessRepository {
  /// Obtiene el negocio por su ID
  ///
  /// Returns:
  /// - Right(Business): Negocio encontrado
  /// - Left(LocalDatabaseFailure): Error al consultar la base de datos
  ///
  /// Validada por Requirement 15.1: Aislamiento multi-tenant
  Future<Either<Failure, Business>> getBusinessById(String businessId);

  /// Obtiene todos los negocios del patrón
  ///
  /// Retorna la lista de todos los negocios donde el usuario es el dueño.
  ///
  /// Parameters:
  /// - ownerId: ID del patrón dueño de los negocios
  ///
  /// Returns:
  /// - Right(List<Business>): Lista de negocios del patrón
  /// - Left(LocalDatabaseFailure): Error al consultar la base de datos
  ///
  /// Validada por Requirement 14.1: Validación de límites de negocios
  Future<Either<Failure, List<Business>>> getBusinessesByOwner(String ownerId);

  /// Crea un nuevo negocio
  ///
  /// Intenta crear un nuevo negocio para el patrón. La validación de
  /// límites debe realizarse en el use case antes de llamar este método.
  ///
  /// Parameters:
  /// - business: Entidad del negocio a crear
  ///
  /// Returns:
  /// - Right(Business): Negocio creado exitosamente
  /// - Left(LocalDatabaseFailure): Error al escribir en la base de datos
  /// - Left(ServerFailure): Error del backend al crear el negocio
  ///
  /// Validada por Requirement 14.1: Creación de negocios
  Future<Either<Failure, Business>> createBusiness(Business business);

  /// Obtiene todos los cajeros vinculados a un negocio
  ///
  /// Retorna la lista de usuarios con rol cajero asociados al negocio.
  ///
  /// Parameters:
  /// - businessId: ID del negocio
  ///
  /// Returns:
  /// - Right(List<User>): Lista de cajeros vinculados
  /// - Left(LocalDatabaseFailure): Error al consultar la base de datos
  ///
  /// Validada por Requirement 12.4: Sección Equipo del Dashboard
  /// Validada por Requirement 14.2: Validación de límites de cajeros
  Future<Either<Failure, List<User>>> getCashiersByBusiness(String businessId);

  /// Vincula un cajero a un negocio
  ///
  /// Asocia un usuario con rol cajero a un negocio específico. La validación
  /// de límites debe realizarse en el use case antes de llamar este método.
  ///
  /// Parameters:
  /// - cashierId: ID del usuario cajero
  /// - businessId: ID del negocio
  ///
  /// Returns:
  /// - Right(void): Vinculación exitosa
  /// - Left(LocalDatabaseFailure): Error al escribir en la base de datos
  /// - Left(ServerFailure): Error del backend al vincular el cajero
  ///
  /// Validada por Requirement 2.4: Vinculación de cajero mediante QR
  /// Validada por Requirement 14.2: Límites de cajeros
  Future<Either<Failure, void>> linkCashierToBusiness({
    required String cashierId,
    required String businessId,
  });
}
