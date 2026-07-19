package com.tacoos.poc.domain.usecase

import java.util.Locale

class FormatTimeUseCase {

    /**
     * Recibe la hora y los minutos en formato de 24 horas y
     * devuelve un String formateado en formato de 12 horas (AM/PM).
     */

    operator fun invoke(hour: Int, minute: Int): String{
        val ampm = if (hour < 12) "AM" else "PM"
        val formattedHour = if (hour == 0) 12 else if (hour > 12) hour - 12 else hour
        return String.format(Locale.getDefault(), "%02d:%02d %s", formattedHour, minute, ampm)
    }

}