package com.tacoos.poc.data.remote

import com.google.gson.Gson
import retrofit2.HttpException

object NetworkUtils {
    private val gson = Gson()

    fun parseError(e: Throwable): String {
        if (e is HttpException) {
            return try {
                val errorBody = e.response()?.errorBody()?.string()
                val errorMap = gson.fromJson(errorBody, Map::class.java)
                
                // Si el backend mandó un campo "mensaje", lo usamos
                val mensaje = errorMap["mensaje"] as? String
                if (!mensaje.isNullOrBlank()) return mensaje

                // Si es un error de validación (Spring)
                val campos = errorMap["campos"] as? Map<*, *>
                if (campos != null) {
                    return "Error en datos: " + campos.entries.joinToString { "${it.key}: ${it.value}" }
                }

                "Error del servidor (${e.code()})"
            } catch (ex: Exception) {
                "Error en la respuesta del servidor"
            }
        }
        return e.message ?: "Error de conexión"
    }
}
