package com.tacoos.poc.domain.usecase.auth

import com.tacoos.poc.domain.model.User
import com.tacoos.poc.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Caso de uso para obtener la sesión actual del usuario.
 * @property authRepository Repositorio de autenticación.
 */
class GetSessionUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    /**
     * Obtiene el flujo de la sesión del usuario.
     * @return Flow que emite el usuario actual o null si no hay sesión.
     */
    operator fun invoke(): Flow<User?> = authRepository.getSession()
}
