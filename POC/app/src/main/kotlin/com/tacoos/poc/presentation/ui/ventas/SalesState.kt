package com.tacoos.poc.presentation.ui.ventas

import android.graphics.Bitmap
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import java.util.*

/**
 * ShiftManager: Gestiona el estado global del turno activo en la sesión de venta.
 */
object ShiftManager {
    var isShiftOpen by mutableStateOf(false)
    var openTimestamp by mutableStateOf(0L)
    var fondoCaja by mutableStateOf(0.0)
    var currentCashier by mutableStateOf("Desconocido")
    var currentShiftId: Long? by mutableStateOf(null)
    
    val sales = mutableStateListOf<POSSale>()
    val expenses = mutableStateListOf<POSExpense>()

    fun clear() {
        isShiftOpen = false
        openTimestamp = 0L
        fondoCaja = 0.0
        currentShiftId = null
        sales.clear()
        expenses.clear()
    }
}

/**
 * POSSale: Representación inmutable de una transacción de venta.
 */
data class POSSale(
    val id: String,
    val amount: Double,
    val method: String,
    val status: String,
    val timestamp: Long = System.currentTimeMillis(),
    val items: List<SaleItemSummary> = emptyList(),
    val voucherPhoto: Bitmap? = null
)

/**
 * SaleItemSummary: Resumen de productos agrupados dentro de una venta.
 */
data class SaleItemSummary(
    val productName: String,
    val totalQuantity: Int,
    val totalPrice: Double
)

/**
 * POSItem: Modelo de datos para artículos del catálogo y carrito.
 */
data class POSItem(
    val name: String,
    val price: Double,
    val category: String,
    var quantity: Int = 0,
    val imagePath: String? = null
)

/**
 * POSExpense: Registro de gastos operativos asociados al corte de caja.
 */
data class POSExpense(
    val id: String = UUID.randomUUID().toString(),
    val detail: String,
    val amount: Double,
    val cashier: String,
    val timestamp: Long = System.currentTimeMillis(),
    val receiptPhoto: Bitmap? = null
)
