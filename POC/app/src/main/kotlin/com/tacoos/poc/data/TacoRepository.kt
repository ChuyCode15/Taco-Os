package com.tacoos.poc.data

import android.graphics.Bitmap
import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.local.AppMetadata
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.local.Sale
import com.tacoos.poc.data.local.Expense
import com.tacoos.poc.data.remote.BusinessRequest
import com.tacoos.poc.data.remote.RegisterRequest
import com.tacoos.poc.data.remote.TacoApi
import com.tacoos.poc.data.remote.SaleRequest
import android.util.Log

/**
 * TacoRepository: Capa de abstracción de datos (Single Source of Truth).
 * Inyección de dependencias: Recibe la interfaz de la API (Retrofit) y la base de datos local (Room).
 * Propósito: Orquestar la comunicación entre el almacenamiento local y la sincronización con el servidor.
 */
class TacoRepository(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    // --- Autenticación y Gestión de Sesión ---

    /**
     * verifyUser: Consulta al servidor si un Google ID ya está registrado.
     */
    suspend fun verifyUser(idGoogle: String) = api.verifyUser(idGoogle)

    /**
     * registerUser: Envía la solicitud de creación de un nuevo perfil de usuario al Backend.
     */
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

    /**
     * createBusiness: Registra los datos del establecimiento vinculado a un dueño.
     */
    suspend fun createBusiness(duenoId: String, nombre: String, direccion: String, giro: String) =
        api.createBusiness(
            duenoId = duenoId,
            request = BusinessRequest(
                nombre = nombre,
                direccion = direccion,
                telefono = "N/A", // Valor predeterminado para el alcance del POC.
                queVende = giro
            )
        )

    /**
     * saveUserLocally: Persiste la información del usuario en SQLite.
     * Actualiza la metadata de sesión para el control de inactividad de 12 horas.
     */
    suspend fun saveUserLocally(user: User) {
        db.userDao().clearUser()
        db.userDao().insertUser(user)
        // Actualizar marca de tiempo del login.
        db.metadataDao().updateMetadata(
            AppMetadata(
                lastLoginTimestamp = System.currentTimeMillis(),
                lastMasterSyncTimestamp = System.currentTimeMillis()
            )
        )
    }

    /**
     * isSessionValid: Valida si la sesión actual ha expirado (límite de 12 horas).
     */
    suspend fun isSessionValid(): Boolean {
        val metadata = db.metadataDao().getMetadata() ?: return false
        val now = System.currentTimeMillis()
        val twelveHours = 12 * 60 * 60 * 1000L
        return (now - metadata.lastLoginTimestamp) < twelveHours
    }

    /**
     * isLicenseValid: Verifica la validez de la licencia localmente contra el tiempo de última sincronización.
     */
    suspend fun isLicenseValid(): Boolean {
        val metadata = db.metadataDao().getMetadata() ?: return false
        val now = System.currentTimeMillis()
        val twentyFourHours = 24 * 60 * 60 * 1000L
        return (now - metadata.lastMasterSyncTimestamp) < twentyFourHours && metadata.isLicenseValid
    }

    // --- Operaciones de Venta (Local First) ---

    /**
     * registerSale: Inserta una transacción de venta en la base de datos local de forma inmediata.
     * Soporta auditoría de método de pago y voucher para cobros con tarjeta.
     */
    suspend fun registerSale(
        amount: Double,
        method: String,
        itemsSummary: String,
        negocioId: String,
        voucherPhoto: Bitmap? = null
    ) {
        db.saleDao().insertSale(
            Sale(
                amount = amount,
                method = method,
                itemsJson = itemsSummary,
                negocioId = negocioId,
                voucherPhoto = voucherPhoto,
                isSynced = false
            )
        )
    }

    /**
     * registerExpense: Persiste un gasto operativo en Room.
     */
    suspend fun registerExpense(
        id: String,
        detail: String,
        amount: Double,
        cashier: String,
        negocioId: String,
        photo: Bitmap? = null
    ) {
        db.expenseDao().insertExpense(
            Expense(
                id = id,
                detail = detail,
                amount = amount,
                cashier = cashier,
                negocioId = negocioId,
                receiptPhoto = photo,
                isSynced = false
            )
        )
    }

    /**
     * getTodayTotal: Recupera la suma total de ventas locales registradas desde el inicio del día actual.
     */
    suspend fun getTodayTotal(): Double {
        val startOfDay = System.currentTimeMillis() - (System.currentTimeMillis() % (24 * 60 * 60 * 1000L))
        return db.saleDao().getTodayTotal(startOfDay) ?: 0.0
    }

    /**
     * getCurrentUser: Recupera el perfil del usuario activo almacenado localmente.
     */
    suspend fun getCurrentUser() = db.userDao().getCurrentUser()
}
