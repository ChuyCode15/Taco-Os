package com.tacoos.poc.domain.usecase.ops

import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.domain.model.DailyCut
import javax.inject.Inject

class PerformDailyCutUseCase @Inject constructor(
    private val repository: TacoRepository
) {
    suspend operator fun invoke(shiftId: Long, actualCash: Double): Result<DailyCut> {
        return try {
            repository.closeShift(shiftId, actualCash)
            // En un caso real, obtendríamos el DailyCut mapeado de la respuesta de la API
            // Por ahora devolvemos un objeto simulado o nulo si no es necesario para el flujo actual
            Result.success(DailyCut(
                id = shiftId.toString(),
                totalSales = 0.0,
                totalExpenses = 0.0,
                cashSales = 0.0,
                cardSales = 0.0,
                expectedCash = 0.0,
                actualCash = actualCash,
                difference = 0.0,
                closedAt = System.currentTimeMillis().toString()
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
