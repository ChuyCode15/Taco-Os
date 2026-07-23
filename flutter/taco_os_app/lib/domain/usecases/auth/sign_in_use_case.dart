import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';

/// Parámetros para el caso de uso de inicio de sesión
///
/// Contiene el flag que indica si el usuario se está registrando o iniciando sesión.
class SignInParams {
  /// Indica si el usuario está registrándose (true) o iniciando sesión (false)
  final bool isRegistration;

  const SignInParams({required this.isRegistration});
}

/// Use case para iniciar sesión con Google Sign-In
///
/// Orquesta el flujo de autenticación con Google y almacenamiento
/// del token JWT en el almacenamiento seguro del dispositivo.
///
/// **Validates: Requirements 1.1, 1.2**
///
/// **Flujo:**
/// 1. Invoca `IAuthRepository.signInWithGoogle()` con el flag isRegistration
/// 2. El repositorio maneja el flujo de Google Sign-In
/// 3. Al éxito, el repositorio almacena el JWT en almacenamiento seguro
/// 4. Retorna el usuario autenticado con perfil y rol
///
/// **Returns:**
/// - `Right(User)`: Autenticación exitosa, usuario con perfil y rol
/// - `Left(AuthFailure)`: Autenticación fallida o cancelada por el usuario
/// - `Left(NetworkFailure)`: Sin conectividad para autenticar
///
/// **Example:**
/// ```dart
/// final result = await signInUseCase(SignInParams(isRegistration: true));
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Bienvenido ${user.displayName}'),
/// );
/// ```
class SignInUseCase extends UseCase<User, SignInParams> {
  final IAuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // No se requiere validación de entrada — Google Sign-In maneja
    // toda la validación de credenciales
    return await repository.signInWithGoogle(
      isRegistration: params.isRegistration,
    );
  }
}
