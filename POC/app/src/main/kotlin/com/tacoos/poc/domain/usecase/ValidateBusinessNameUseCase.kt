package com.tacoos.poc.domain.usecase

import jakarta.inject.Inject

/**
 * Valida que el nombre del negocio no esté vacío y tenga al menos 3 caracteres.
 */
class ValidateBusinessNameUseCase @Inject constructor() {
    /**
     * Ejecuta la validación del nombre del negocio.
     * @param nombre El nombre a validar.
     * @return true si es válido, false en caso contrario.
     */
    operator fun invoke(nombre: String): Boolean {
        return nombre.isNotBlank() && nombre.length >= 3
    }
}