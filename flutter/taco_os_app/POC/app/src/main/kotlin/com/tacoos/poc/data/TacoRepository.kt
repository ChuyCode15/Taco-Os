package com.tacoos.poc.data

import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.local.AppMetadata
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.remote.RegisterRequest
import com.tacoos.poc.data.remote.TacoApi
import java.util.UUID

class TacoRepository(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    // --- Auth & Session ---
    suspend fun verifyUser(idGoogle: String) = api.verifyUser(idGoogle)

    suspend fun registerUser(
        idGoogle: String,
        nombre: String,
        email: String,
        fotoUrl: String?,
        rol: String
    ) = api.registerUser(RegisterRequest(idGoogle, nombre, email, fotoUrl, rol))

    suspend fun saveUserLocally(user: User) {
        db.userDao().clearUser()
        db.userDao().insertUser(user)
        // Actualizar inicio de sesión (12h clock starts)
        db.metadataDao().updateMetadata(
            AppMetadata(
                lastLoginTimestamp = System.currentTimeMillis(),
                lastMasterSyncTimestamp = System.currentTimeMillis() // Suponemos sync exitoso al login
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

    // --- Sales (Local First) ---
    suspend fun registerSale(amount: Double, negocioId: String) {
        // Registro inmediato en SQLite para máxima agilidad
        db.saleDao().insertSale(
            com.tacoos.poc.data.local.Sale(
                amount = amount,
                negocioId = negocioId,
                isSynced = false
            )
        )
    }

    suspend fun getTodayTotal(): Double {
        val startOfDay = System.currentTimeMillis() - (System.currentTimeMillis() % (24 * 60 * 60 * 1000L))
        return db.saleDao().getTodayTotal(startOfDay) ?: 0.0
    }

    suspend fun getCurrentUser() = db.userDao().getCurrentUser()
}
