package com.tacoos.poc.ui.screens

import androidx.compose.runtime.*
import com.tacoos.poc.data.local.*

/**
 * ShiftManager: Mantiene el estado volátil de la UI para respuesta inmediata.
 */
object ShiftManager {
    var isShiftOpen by mutableStateOf(false)
    var activeShiftId by mutableStateOf<String?>(null)
    var openTimestamp by mutableStateOf(0L)
    var fondoCaja by mutableStateOf(0.0)
    var currentCashier by mutableStateOf("Desconocido")
    
    val sales = mutableStateListOf<SaleNote>()
    val expenses = mutableStateListOf<Expense>()
}

/**
 * POSItem: Modelo de datos para artículos del catálogo (UI).
 */
data class POSItem(
    val name: String,
    val price: Double,
    val category: String,
    var quantity: Int = 0
)
