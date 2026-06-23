import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';

/// Use case para cerrar sesión del usuario actual
///
/// Orquesta el proceso de cierre de sesión eliminando el token JWT
/// del almacenamiento seguro y limpiando los datos de identidad y rol
/// de la memoria de la aplicación.
///
/// **Validates: Requirements 1.9**
///
/// **Flujo:**
/// 1. Invoca `IAuthRepository.signOut()`
/// 2. El repositorio elimina el JWT del almacenamiento seguro
/// 3. El repositorio limpia los datos de identidad de memoria
/// 4. Retorna void al éxito
///
/// **Returns:**
/// - `Right(void)`: Sesión cerrada exitosamente
/// - `Left(Failure)`: Error al cerrar sesión (raramente ocurre)
///
/// **Example:**
/// ```dart
/// final result = await signOutUseCase(NoParams());
/// result.fold(
///   (failure) => print('Error al cerrar sesión'),
///   (_) => navigateToLogin(),
/// );
/// ```
class SignOutUseCase extends UseCase<void, NoParams> {
  final IAuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // No se requiere validación de entrada
    return await repository.signOut();
  }
}
