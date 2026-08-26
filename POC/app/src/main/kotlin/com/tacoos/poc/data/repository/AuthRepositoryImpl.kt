package com.tacoos.poc.data.repository

import com.tacoos.poc.core.util.AppResult
import com.tacoos.poc.data.local.UserPreferences
import com.tacoos.poc.data.mapper.toDomain
import com.tacoos.poc.data.remote.AuthApiService
import com.tacoos.poc.data.remote.dto.DatosRegistroAuth
import com.tacoos.poc.domain.model.User
import com.tacoos.poc.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementación del repositorio de autenticación que coordina las llamadas a la API
 * y la persistencia local de la sesión del usuario.
 */
@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val api: AuthApiService,
    private val preferences: UserPreferences
) : AuthRepository {

    /**
     * Realiza el proceso de inicio de sesión con Google.
     * Intenta verificar al usuario y, si no existe, lo registra automáticamente.
     * @param idToken Token de identidad proporcionado por Google.
     * @param idGoogle Identificador único de Google.
     * @param email Correo electrónico del usuario.
     * @param nickname Apodo del usuario (opcional).
     * @return [AppResult] con el usuario autenticado o un error.
     */
    override suspend fun signInWithGoogle(
        idToken: String,
        idGoogle: String,
        email: String,
        nickname: String?
    ): AppResult<User> {
        return try {
            // 1. Intentar verificar si el usuario existe
            try {
                val verification = api.verifyUser(idGoogle)
                if (verification.existe && verification.usuario != null) {
                    val user = verification.usuario.toDomain()
                    preferences.saveSession(user, verification.token ?: "", null)
                    return AppResult.Success(user)
                }
                // Si existe es false, caemos al flujo de registro abajo
            } catch (e: HttpException) {
                // Si el backend devuelve 404, significa que el usuario no existe (según el comportamiento observado)
                if (e.code() != 404) {
                    return AppResult.Error("Error en el servidor (${e.code()})", e)
                }
                // Si es 404, continuamos al registro
            }

            // 2. Si no existe o recibimos 404, procedemos al registro automático
            val registration = api.registerUser(
                DatosRegistroAuth(
                    idGoogle = idGoogle,
                    nickname = nickname ?: email.substringBefore("@"),
                    correo = email,
                    numero = "",
                    rol = "dueño"
                )
            )
            val user = registration.usuario.toDomain()
            preferences.saveSession(user, registration.token, null)
            AppResult.Success(user)

        } catch (e: HttpException) {
            AppResult.Error("Error al registrar usuario (${e.code()})", e)
        } catch (e: IOException) {
            AppResult.Error("Sin conexión con el servidor", e)
        } catch (e: Exception) {
            AppResult.Error("Error inesperado: ${e.message}", e)
        }
    }

    /**
     * Proporciona un flujo continuo con el estado actual de la sesión del usuario.
     */
    override fun getSession(): Flow<User?> = preferences.session

    /**
     * Cierra la sesión activa y limpia los datos locales.
     */
    override suspend fun logout() {
        preferences.clear()
    }
}
