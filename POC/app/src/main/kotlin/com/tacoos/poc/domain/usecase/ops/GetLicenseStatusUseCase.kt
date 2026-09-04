package com.tacoos.poc.domain.usecase.ops

import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.domain.model.LicenseStatus
import javax.inject.Inject

class GetLicenseStatusUseCase @Inject constructor(
    private val repository: TacoRepository
) {
    suspend operator fun invoke(negocioId: String): Result<LicenseStatus> {
        return try {
            // Simulación para el POC
            Result.success(LicenseStatus(
                negocioId = negocioId,
                status = "ACTIVE",
                expiryDate = "2027-01-01",
                planName = "Premium POC"
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
