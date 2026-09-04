package com.tacoos.poc.domain.usecase.ops

import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.domain.model.Expense
import javax.inject.Inject

class GetExpensesUseCase @Inject constructor(
    private val repository: TacoRepository
) {
    suspend operator fun invoke(shiftId: Long): List<Expense> {
        // En el POC devolvemos una lista vacía o simulada
        return emptyList()
    }
}
