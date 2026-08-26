package com.tacoos.poc.domain.repository

import com.tacoos.poc.core.util.AppResult
import com.tacoos.poc.domain.model.User
import kotlinx.coroutines.flow.Flow

/**
 * Interfaz que define las operaciones de autenticación permitidas por el dominio.
 * Sigue el patrón de inversión de dependencias para desacoplar el dominio de la capa de datos.
 */
interface AuthRepository {

    /**
     * Inicia el proceso de autenticación mediante el proveedor de identidad de Google.
     * @param idToken Token de identidad de Google.
     * @param idGoogle ID único de usuario de Google.
     * @param email Correo recuperado de Google.
     * @param nickname Nombre sugerido del usuario.
     * @return El resultado de la operación encapsulado en un [AppResult].
     */
    suspend fun signInWithGoogle(
        idToken: String,
        idGoogle: String,
        email: String,
        nickname: String?
    ): AppResult<User>

    /**
     * Proporciona acceso al estado de la sesión actual de forma reactiva.
     * @return Un [Flow] que emite el usuario actual o null si no hay sesión.
     */
    fun getSession(): Flow<User?>

    /**
     * Finaliza la sesión actual y limpia la persistencia local.
     */
    suspend fun logout()
}
