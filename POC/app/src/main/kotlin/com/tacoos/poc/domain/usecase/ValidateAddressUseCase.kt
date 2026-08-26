package com.tacoos.poc.domain.usecase

import jakarta.inject.Inject

/**
 * Valida que el domicilio no esté vacío y tenga al menos 5 caracteres.
 */
class ValidateAddressUseCase @Inject constructor() {
    /**
     * Ejecuta la validación del domicilio.
     * @param domicilio El texto del domicilio a validar.
     * @return true si es válido, false en caso contrario.
     */
    operator fun invoke(domicilio: String): Boolean {
        return domicilio.isNotBlank() && domicilio.length >= 5
    }
}