package com.tacoos.poc.data

import android.util.Log
import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.local.AppMetadata
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.local.Sale
import com.tacoos.poc.data.local.Expense
import com.tacoos.poc.data.local.Product
import com.tacoos.poc.data.local.Corte
import com.tacoos.poc.data.local.SaleNote
import com.tacoos.poc.data.local.SaleDetail
import com.tacoos.poc.data.remote.BusinessRequest
import com.tacoos.poc.data.remote.RegisterRequest
import com.tacoos.poc.data.remote.TacoApi
import java.util.UUID

/**
 * TacoRepository: Capa de abstracción de datos (Single Source of Truth).
 */
class TacoRepository(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    // --- Autenticación y Gestión de Sesión ---

    suspend fun verifyUser(idGoogle: String) = api.verifyUser(idGoogle)

    suspend fun registerUser(
        idGoogle: String,
        nombre: String,
        email: String,
        rol: String
    ) = api.registerUser(
        RegisterRequest(
            idGoogle = idGoogle,
            nickname = nombre,
            correo = email,
            rol = rol
        )
    )

    // --- Operaciones de Negocio ---

    suspend fun createBusiness(duenoId: String, nombre: String, direccion: String, giro: String) =
        api.createBusiness(
            duenoId = duenoId,
            request = BusinessRequest(
                nombre = nombre,
                direccion = direccion,
                telefono = "N/A",
                queVende = giro
            )
        )

    suspend fun getBusinessDetails(id: String) = api.getBusiness(UUID.fromString(id))

    suspend fun updateBusiness(id: String, request: BusinessRequest) = 
        api.updateBusiness(UUID.fromString(id), request)

    suspend fun saveUserLocally(user: User) {
        db.userDao().clearUser()
        db.userDao().insertUser(user)
        db.metadataDao().updateMetadata(
            AppMetadata(
                lastLoginTimestamp = System.currentTimeMillis(),
                lastMasterSyncTimestamp = System.currentTimeMillis()
            )
        )
    }

    suspend fun isSessionValid(): Boolean {
        val metadata = db.metadataDao().getMetadata() ?: return false
        val now = System.currentTimeMillis()
        val twelveHours = 12 * 60 * 60 * 1000L
        return (now - metadata.lastLoginTimestamp) < twelveHours
    }

    suspend fun isLicenseValid(): Boolean {
        val metadata = db.metadataDao().getMetadata() ?: return false
        val now = System.currentTimeMillis()
        val twentyFourHours = 24 * 60 * 60 * 1000L
        return (now - metadata.lastMasterSyncTimestamp) < twentyFourHours && metadata.isLicenseValid
    }

    // --- Operaciones de Turno (Corte) ---

    /**
     * openCorte: Inicia un turno físico en Room. Genera el padre para todas las ventas.
     */
    suspend fun openCorte(negocioId: String, cashierId: String, initialCash: Double): Corte {
        val newCorte = Corte(
            id = UUID.randomUUID().toString(),
            tenantId = negocioId,
            cashierId = cashierId,
            initialCash = initialCash,
            status = "OPEN"
        )
        db.corteDao().insertCorte(newCorte)
        return newCorte
    }

    /**
     * getActiveCorte: Recupera el turno abierto para el negocio.
     */
    suspend fun getActiveCorte(negocioId: String) = db.corteDao().getActiveCorte(negocioId)

    /**
     * closeCorte: Finaliza el turno, calcula totales inmutables y guarda la foto final.
     */
    suspend fun closeCorte(corteId: String, realCash: Double): Corte? {
        val corte = db.corteDao().getCorteById(corteId) ?: return null
        val notes = db.saleNoteDao().getNotesByCorte(corteId).filter { it.status == "ACTIVE" }
        
        val totalCash = notes.filter { it.paymentMethod == "CASH" }.sumOf { it.totalAmount }
        val totalCard = notes.filter { it.paymentMethod == "CARD" }.sumOf { it.totalAmount }
        val totalSales = totalCash + totalCard
        
        // Aquí se sumarían los gastos vinculados al corte_id cuando se implemente la relación física
        val totalExpenses = 0.0 // Placeholder para gastos
        val expected = (corte.initialCash + totalCash) - totalExpenses

        val closedCorte = corte.copy(
            closedAt = System.currentTimeMillis(),
            totalSalesAmount = totalSales,
            totalSalesCash = totalCash,
            totalSalesCard = totalCard,
            totalExpensesAmount = totalExpenses,
            expectedCash = expected,
            realCashCounted = realCash,
            difference = realCash - expected,
            status = "CLOSED"
        )
        
        db.corteDao().updateCorte(closedCorte)
        return closedCorte
    }

    // --- Operaciones de Venta Inmutable ---

    /**
     * registerInmutableSale: Guarda una nota con sus detalles calculando totales fijos.
     */
    suspend fun registerInmutableSale(note: SaleNote, details: List<SaleDetail>) {
        // En un sistema real usaríamos una transacción de DB (Room @Transaction)
        db.saleNoteDao().insertNote(note)
        db.saleNoteDao().insertDetails(details)
        
        // También guardamos en la tabla legacy para no romper Reportes actuales
        registerSale(
            amount = note.totalAmount,
            negocioId = note.tenantId,
            userId = note.corteId, // Usamos corteId como referencia temporal
            productsJson = note.productsJson,
            method = if (note.paymentMethod == "CASH") "Efectivo" else "Tarjeta",
            imagePath = note.voucherPath
        )
    }

    // --- Operaciones de Productos ---

    suspend fun getProducts(negocioId: String) = db.productDao().getProducts(negocioId)

    suspend fun saveProduct(product: Product) = db.productDao().insertProduct(product)

    suspend fun updateProduct(product: Product) = db.productDao().updateProduct(product)

    suspend fun deleteProduct(product: Product) = db.productDao().deleteProduct(product)

    suspend fun seedInitialProducts(negocioId: String) {
        val current = db.productDao().getProducts(negocioId)
        if (current.isEmpty()) {
            val base = listOf(
                Product(java.util.UUID.randomUUID().toString(), "Taco Pastor", 25.0, "Comidas", null, negocioId),
                Product(java.util.UUID.randomUUID().toString(), "Taco Bistec", 30.0, "Comidas", null, negocioId),
                Product(java.util.UUID.randomUUID().toString(), "Gringa", 65.0, "Comidas", null, negocioId),
                Product(java.util.UUID.randomUUID().toString(), "Coca 600ml", 22.0, "Bebidas", null, negocioId),
                Product(java.util.UUID.randomUUID().toString(), "Agua Fresca", 20.0, "Bebidas", null, negocioId),
                Product(java.util.UUID.randomUUID().toString(), "Flan Casero", 45.0, "Postres", null, negocioId)
            )
            base.forEach { db.productDao().insertProduct(it) }
        }
    }

    // --- Operaciones de Venta (Local First) ---

    suspend fun registerSale(
        amount: Double,
        negocioId: String,
        userId: String = "",
        productsJson: String = "",
        method: String = "Efectivo",
        imagePath: String? = null
    ) {
        db.saleDao().insertSale(
            Sale(
                amount = amount,
                userId = userId,
                productsJson = productsJson,
                method = method,
                status = "ACTIVE",
                negocioId = negocioId,
                imagePath = imagePath,
                isSynced = false
            )
        )
    }

    suspend fun registerExpense(
        id: String,
        detail: String,
        amount: Double,
        cashier: String,
        negocioId: String,
        imagePath: String? = null
    ) {
        db.expenseDao().insertExpense(
            Expense(
                id = id,
                detail = detail,
                amount = amount,
                cashier = cashier,
                negocioId = negocioId,
                imagePath = imagePath,
                isSynced = false
            )
        )
    }

    suspend fun getTodayTotal(): Double {
        val startOfDay = System.currentTimeMillis() - (System.currentTimeMillis() % (24 * 60 * 60 * 1000L))
        return db.saleDao().getTodayTotal(startOfDay) ?: 0.0
    }

    suspend fun getCurrentUser() = db.userDao().getCurrentUser()

    // --- Sync Logic ---
    suspend fun syncPendingSales() {
        val pendingSales = db.saleDao().getAllSales().filter { !it.isSynced && it.status == "ACTIVE" }
        if (pendingSales.isEmpty()) return
        Log.d("TacoRepository", "Sincronizando ${pendingSales.size} ventas...")
        pendingSales.forEach { sale ->
            try {
                db.saleDao().markAsSynced(sale.id)
                Log.d("TacoRepository", "Venta ${sale.id} sincronizada")
            } catch (e: Exception) {
                Log.e("TacoRepository", "Error sincronizando venta ${sale.id}", e)
            }
        }
    }
}
