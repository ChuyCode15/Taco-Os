package com.tacoos.poc.data

import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.local.AppMetadata
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.local.Sale as LocalSale
import com.tacoos.poc.data.remote.BusinessRequest
import com.tacoos.poc.data.remote.RegisterRequest
import com.tacoos.poc.data.remote.TacoApi
import com.tacoos.poc.data.remote.SaleRequest
import android.util.Log

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
    suspend fun registerSale(amount: Double, negocioId: String, userId: String, productsJson: String) {
        db.saleDao().insertSale(
            LocalSale(
                amount = amount,
                negocioId = negocioId,
                userId = userId,
                productsJson = productsJson,
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
                // Mapear al modelo de la API y enviar
                // val response = api.uploadSale(sale.negocioId, SaleRequest(...))
                // if (response.isSuccessful) {
                //    db.saleDao().markAsSynced(sale.id)
                // }
                
                // Simulación exitosa para el POC
                // db.saleDao().markAsSynced(sale.id) 
            } catch (e: Exception) {
                Log.e("TacoRepository", "Error sincronizando venta ${sale.id}", e)
            }
        }
    }
}
