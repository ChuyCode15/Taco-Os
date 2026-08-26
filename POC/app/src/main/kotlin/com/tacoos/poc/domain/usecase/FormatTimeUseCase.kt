package com.tacoos.poc.domain.usecase

import javax.inject.Inject
import java.util.Locale

/**
 * Caso de uso que recibe la hora y los minutos en formato 24h
 * y devuelve un String formateado en formato 12h (AM/PM).
 */
class FormatTimeUseCase @Inject constructor() {

    /**
     * Ejecuta la lógica de formateo de tiempo.
     * @param hour Hora en formato 24h (0-23).
     * @param minute Minutos (0-59).
     * @return String formateado como "HH:mm AM/PM".
     */
    operator fun invoke(hour: Int, minute: Int): String {
        val ampm = if (hour < 12) "AM" else "PM"
        val formattedHour = when {
            hour == 0 -> 12
            hour > 12 -> hour - 12
            else -> hour
        }
        return String.format(Locale.getDefault(), "%02d:%02d %s", formattedHour, minute, ampm)
    }
}
