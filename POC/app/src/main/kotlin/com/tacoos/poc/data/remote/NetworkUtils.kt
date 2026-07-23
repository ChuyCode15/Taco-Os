package com.tacoos.poc.data.remote

import com.google.gson.Gson
import retrofit2.HttpException

/**
 * NetworkUtils: Utilidad para la gestión y parseo de respuestas de error de red.
 */
object NetworkUtils {
    private val gson = Gson()

    /**
     * parseError: Convierte una excepción de red en un mensaje de texto legible para el usuario.
     * Inyección de lógica: Analiza el cuerpo JSON de la respuesta de error enviada por el Backend.
     */
    fun parseError(e: Throwable): String {
        if (e is HttpException) {
            return try {
                val errorBody = e.response()?.errorBody()?.string()
                val errorMap = gson.fromJson(errorBody, Map::class.java)
                
                // Prioridad 1: Campo "mensaje" explícito del servidor.
                val mensaje = errorMap["mensaje"] as? String
                if (!mensaje.isNullOrBlank()) return mensaje

                // Manejo específico por código HTTP
                when (e.code()) {
                    409 -> return "El usuario o negocio ya existe."
                    401 -> return "Sesión no autorizada."
                    404 -> return "Recurso no encontrado."
                    500 -> return "Error interno del servidor."
                }

                // Prioridad 2: Errores de validación de campos (Spring Boot Style).
                val campos = errorMap["campos"] as? Map<*, *>
                if (campos != null) {
                    return "Error en datos: " + campos.entries.joinToString { "${it.key}: ${it.value}" }
                }

                "Error del servidor (${e.code()})"
            } catch (ex: Exception) {
                "Error en la respuesta del servidor"
            }
        }
        // Manejo de errores de conectividad general (Offline).
        return e.message ?: "Error de conexión"
    }
}
