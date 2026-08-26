package com.tacoos.poc.core.util

/**
 * Representa el resultado de una operación que puede ser un éxito, un error o estar en carga.
 * @param T Tipo de dato devuelto en caso de éxito.
 */
sealed class AppResult<out T> {
    /**
     * Representa una operación exitosa.
     * @property data Los datos resultantes de la operación.
     */
    data class Success<out T>(val data: T) : AppResult<T>()

    /**
     * Representa un fallo en la operación.
     * @property message Mensaje descriptivo del error.
     * @property exception Excepción opcional que causó el fallo.
     */
    data class Error(val message: String, val exception: Throwable? = null) : AppResult<Nothing>()

    /**
     * Indica que la operación está actualmente en proceso.
     */
    object Loading : AppResult<Nothing>()
}
