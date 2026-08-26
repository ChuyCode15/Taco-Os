package com.tacoos.poc.domain.usecase

import jakarta.inject.Inject

/**
 * Valida que el giro (actividad del negocio) no esté vacío.
 */
class ValidateGiroUseCase @Inject constructor() {
    /**
     * Ejecuta la validación del giro.
     * @param giro El texto del giro a validar.
     * @return true si no está en blanco, false en caso contrario.
     */
    operator fun invoke(giro: String): Boolean {
        return giro.isNotBlank()
    }
}