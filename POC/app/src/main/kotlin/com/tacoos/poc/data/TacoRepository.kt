package com.tacoos.poc.data

import android.util.Log
import com.tacoos.poc.data.local.*
import com.tacoos.poc.data.remote.TacoApi
import com.tacoos.poc.data.remote.dto.*
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TacoRepository @Inject constructor(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    // --- SESIONES Y CORTE ---
    suspend fun getActiveShift(negocioId: String): Shift? = db.shiftDao().getActiveShiftByBusiness(negocioId)

    suspend fun openShift(shift: Shift): Long {
        try {
            api.openSession(DatosAperturaSesion(
                negocioId = shift.negocioId,
                cajeroId = shift.userId,
                dispositivoId = "Android-Device",
                fondoApertura = shift.initialAmount
            ))
        } catch (e: Exception) {
            Log.e("TacoRepository", "Error opening remote session: ${e.message}")
        }
        return db.shiftDao().insertShift(shift)
    }

    suspend fun updateShift(shift: Shift) {
        db.shiftDao().updateShift(shift)
    }

    suspend fun closeShift(shiftId: Long, efectivoContado: Double) {
        val shift = db.shiftDao().getShiftById(shiftId) ?: return
        
        val totalSalesCash = db.saleDao().getShiftCashSales(shiftId) ?: 0.0
        val totalExpenses = db.expenseDao().getShiftTotalExpenses(shiftId) ?: 0.0
        val expectedCash = shift.initialAmount + totalSalesCash - totalExpenses
        
        try {
            api.closeSession(DatosCierreSesion(
                sesionId = shiftId.toString(),
                efectivoReal = efectivoContado,
                notas = "Cierre local"
            ))
        } catch (e: Exception) {
            Log.e("TacoRepository", "Error closing remote session: ${e.message}")
        }

        val updatedShift = shift.copy(
            closeTimestamp = System.currentTimeMillis(),
            efectivoContado = efectivoContado,
            diferencia = efectivoContado - expectedCash,
            status = "CLOSED"
        )
        db.shiftDao().updateShift(updatedShift)
    }

    // --- VENTAS ---
    suspend fun registerSale(
        amount: Double,
        negocioId: String,
        userId: String,
        productsJson: String,
        method: String,
        imagePath: String?,
        shiftId: Long?
    ) {
        db.saleDao().insertSale(
            Sale(
                shiftId = shiftId,
                amount = amount,
                productsJson = productsJson,
                paymentMethod = method,
                negocioId = negocioId,
                userId = userId,
                cancelPhotoPath = imagePath
            )
        )
    }

    suspend fun getShiftSales(shiftId: Long) = db.saleDao().getSalesByShift(shiftId)

    // --- GASTOS ---
    suspend fun registerExpense(
        id: String,
        detail: String,
        amount: Double,
        cashier: String,
        negocioId: String,
        imagePath: String?,
        shiftId: Long?
    ) {
        db.expenseDao().insertExpense(
            Expense(
                shiftId = shiftId,
                detail = detail,
                amount = amount,
                cashier = cashier,
                negocioId = negocioId,
                imagePath = imagePath
            )
        )
    }

    // --- PRODUCTOS ---
    suspend fun getProducts(negocioId: String): List<Product> {
        return db.productDao().getProducts(negocioId)
    }

    suspend fun saveProduct(product: Product) {
        db.productDao().insertProducts(listOf(product))
    }

    suspend fun updateProduct(product: Product) {
        db.productDao().insertProducts(listOf(product))
    }

    suspend fun deleteProduct(product: Product) {
        // Implementar borrado si es necesario
    }

    suspend fun seedInitialProducts(negocioId: String) {
        val existing = db.productDao().getProducts(negocioId)
        if (existing.isEmpty()) {
            val initials = listOf(
                Product(id = UUID.randomUUID().toString(), name = "Taco Pastor", price = 25.0, category = "Comidas", negocioId = negocioId),
                Product(id = UUID.randomUUID().toString(), name = "Refresco 600ml", price = 20.0, category = "Bebidas", negocioId = negocioId)
            )
            db.productDao().insertProducts(initials)
        }
    }

    // --- SUMARIOS ---
    suspend fun getShiftSummary(shiftId: Long): ShiftSummary {
        val totalSales = db.saleDao().getShiftTotalSales(shiftId) ?: 0.0
        val salesCount = db.saleDao().getShiftSalesCount(shiftId)
        val totalExpenses = db.expenseDao().getShiftTotalExpenses(shiftId) ?: 0.0
        val cashSales = db.saleDao().getShiftCashSales(shiftId) ?: 0.0
        val cardSales = db.saleDao().getShiftCardSales(shiftId) ?: 0.0
        
        return ShiftSummary(
            totalSales = totalSales,
            salesCount = salesCount,
            totalExpenses = totalExpenses,
            cashSales = cashSales,
            cardSales = cardSales
        )
    }

    // --- NEGOCIO ---
    suspend fun getBusinessDetails(negocioId: String): DatosDetalleNegocio {
        // En un caso real esto llamaría a la API. Para el POC devolvemos datos locales si existen
        // o simulamos una llamada.
        return DatosDetalleNegocio(
            id = negocioId,
            nombre = "Tacos El Profe",
            direccion = "Av. Siempre Viva 123",
            telefono = "555-1234",
            giro = "Tacos",
            empleados = 3,
            horarioCierre = "23:00",
            registro = "2023-01-01"
        )
    }

    suspend fun updateBusiness(negocioId: String, request: BusinessRequest) {
        api.createBusiness(negocioId, request)
    }
    
    suspend fun syncPendingSales() {
        // Lógica de sincronización masiva
    }
}

data class ShiftSummary(
    val totalSales: Double,
    val salesCount: Int,
    val totalExpenses: Double,
    val cashSales: Double,
    val cardSales: Double
)
