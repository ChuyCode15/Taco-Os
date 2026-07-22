package com.tacoos.poc.data

import com.tacoos.poc.data.local.*
import com.tacoos.poc.data.remote.BusinessRequest
import com.tacoos.poc.data.remote.RegisterRequest
import com.tacoos.poc.data.remote.TacoApi

/**
 * TacoRepository: Capa de abstracción de datos (Single Source of Truth).
 */
class TacoRepository(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    // --- Autenticación ---

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

    suspend fun getCurrentUser() = db.userDao().getCurrentUser()

    // --- Sesiones (Caja) ---

    suspend fun openShift(businessId: String, cashierId: String, tenantId: String, initialCash: Double) {
        val shift = Shift(
            businessId = businessId,
            cashierId = cashierId,
            tenantId = tenantId,
            initialCash = initialCash
        )
        db.shiftDao().openShift(shift)
    }

    suspend fun getActiveShift(businessId: String) = db.shiftDao().getActiveShift(businessId)

    // --- Transacciones ---

    suspend fun saveSaleWithDetails(note: SaleNote, details: List<SaleDetail>) {
        db.saleDao().insertNote(note)
        db.saleDao().insertDetails(details)
    }

    suspend fun getNotesByShift(shiftId: String) = db.saleDao().getNotesByShift(shiftId)

    suspend fun updateNote(note: SaleNote) {
        db.saleDao().updateNote(note)
    }

    // --- Cortes ---

    suspend fun updateShift(shift: Shift) {
        db.shiftDao().updateShift(shift)
    }

    // --- Gastos ---

    suspend fun saveExpense(expense: Expense) {
        db.expenseDao().insertExpense(expense)
    }

    suspend fun getExpensesByShift(shiftId: String) = db.expenseDao().getExpensesByShift(shiftId)

    // --- Mantenimiento ---

    suspend fun pruneSyncedData() {
        val threshold = System.currentTimeMillis() - (24 * 60 * 60 * 1000L)
        db.saleDao().pruneSyncedSales(threshold)
        db.expenseDao().pruneSyncedExpenses(threshold)
        db.shiftDao().pruneSyncedShifts(threshold)

        val meta = db.metadataDao().getMetadata()
        meta?.let {
            db.metadataDao().updateMetadata(it.copy(lastPruneTimestamp = System.currentTimeMillis()))
        }
    }
}
