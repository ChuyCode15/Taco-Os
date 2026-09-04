package com.tacoos.poc.domain.usecase.ops

import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.domain.model.AppNotification
import javax.inject.Inject

class GetNotificationsUseCase @Inject constructor(
    private val repository: TacoRepository
) {
    suspend operator fun invoke(): List<AppNotification> {
        // Simulación para el POC
        return listOf(
            AppNotification("1", "Bienvenido", "Gracias por usar Taco-Os", System.currentTimeMillis(), false),
            AppNotification("2", "Licencia Próxima a Vencer", "Tu plan vence en 30 días", System.currentTimeMillis() - 86400000, true)
        )
    }
}
