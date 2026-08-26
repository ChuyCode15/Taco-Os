package com.tacoos.poc.data.remote

import com.tacoos.poc.data.local.UserPreferences
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject

/**
 * Interceptor de red que añade la cabecera de autorización "Authorization: Bearer <token>"
 * a todas las peticiones salientes si el usuario tiene una sesión activa.
 */
class AuthInterceptor @Inject constructor(
    private val userPreferences: UserPreferences
) : Interceptor {

    /**
     * Intercepta la petición actual para inyectar el token de acceso.
     * La obtención del token es síncrona gracias al uso de almacenamiento cifrado,
     * evitando bloqueos de corrutinas en la capa de red.
     * 
     * @param chain Cadena de interceptores de OkHttp.
     * @return Respuesta de la petición ejecutada con la cabecera de seguridad añadida.
     */
    override fun intercept(chain: Interceptor.Chain): Response {
        val token = userPreferences.getAccessToken()

        val request = chain.request().newBuilder()
        
        if (!token.isNullOrBlank()) {
            request.addHeader("Authorization", "Bearer $token")
        }

        return chain.proceed(request.build())
    }
}
