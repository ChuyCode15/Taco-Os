package com.tacoos.poc.domain.usecase.auth

import com.tacoos.poc.core.util.AppResult
import com.tacoos.poc.domain.model.User
import com.tacoos.poc.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * Una sola responsabilidad: iniciar sesión con Google.
 * Ahora orquestado por el repositorio para verificar/registrar.
 */
class SignInWithGoogleUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    /**
     * Ejecuta el inicio de sesión con credenciales de Google.
     * @param idToken Token de identificación de Google.
     * @param idGoogle ID único de Google del usuario.
     * @param email Correo electrónico del usuario.
     * @param nickname Nombre o apodo del usuario.
     * @return Resultado de la operación con el usuario autenticado o error.
     */
    suspend operator fun invoke(
        idToken: String,
        idGoogle: String,
        email: String,
        nickname: String?
    ): AppResult<User> {
        if (idToken.isBlank() || idGoogle.isBlank()) {
            return AppResult.Error("Datos de Google inválidos")
        }
        return authRepository.signInWithGoogle(idToken, idGoogle, email, nickname)
    }
}
