package com.tacoos.poc.data

import android.util.Log
import com.google.gson.Gson
import com.tacoos.poc.data.local.*
import com.tacoos.poc.data.remote.*
import com.tacoos.poc.ui.screens.GoogleSignInState
import java.util.UUID

/**
 * TacoRepository: Gestiona la persistencia local y la sincronización con el servidor.
 */
class TacoRepository(
    private val api: TacoApi,
    private val db: AppDatabase
) {
    private val gson = Gson()

    // --- Autenticación ---
    suspend fun verifyUser(idGoogle: String) = api.verifyUser(idGoogle)
    
    suspend fun registerUser(idGoogle: String, nombre: String, email: String, rol: String) = 
        api.registerUser(RegisterRequest(idGoogle, nickname = nombre, correo = email, rol = rol))

    // --- Gestión Local ---
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
    suspend fun getCashiers(negocioId: String) = db.userDao().getCashiers(negocioId)

    // --- Gestión de Negocio ---
    suspend fun getBusinessDetails(id: String) = api.getBusiness(UUID.fromString(id))

    suspend fun createBusiness(duenoId: String, nombre: String, direccion: String, giro: String): BusinessResponse {
        return api.createBusiness(
            duenoId = duenoId,
            request = BusinessRequest(
                nombre = nombre,
                direccion = direccion,
                telefono = "N/A",
                queVende = giro
            )
        )
    }

    suspend fun updateBusiness(id: String, request: BusinessRequest): BusinessResponse {
        return api.updateBusiness(UUID.fromString(id), request)
    }

    // --- Gestión de Productos ---
    suspend fun getProducts(negocioId: String) = db.productDao().getProducts(negocioId)
    suspend fun saveProduct(product: Product) = db.productDao().insertProduct(product)
    suspend fun updateProduct(product: Product) = db.productDao().updateProduct(product)
    suspend fun deleteProduct(product: Product) = db.productDao().deleteProduct(product)

    suspend fun seedInitialProducts(negocioId: String) {
        val existing = getProducts(negocioId)
        if (existing.isEmpty()) {
            val defaults = listOf(
                Product(UUID.randomUUID().toString(), "Taco Pastor", 25.0, "Tacos", null, negocioId),
                Product(UUID.randomUUID().toString(), "Taco Suadero", 25.0, "Tacos", null, negocioId),
                Product(UUID.randomUUID().toString(), "Refresco 600ml", 20.0, "Bebidas", null, negocioId),
                Product(UUID.randomUUID().toString(), "Agua Litro", 15.0, "Bebidas", null, negocioId)
            )
            defaults.forEach { db.productDao().insertProduct(it) }
        }
    }

    // --- Turnos (Sesiones de Caja) ---
    suspend fun getActiveShift(negocioId: String): Shift? = db.shiftDao().getActiveShift(negocioId)
    
    suspend fun openShift(shift: Shift): Long {
        var finalShift = shift
        try {
            val body = mapOf(
                "business_id" to shift.negocioId,
                "cashier_id" to GoogleSignInState.userId,
                "initial_amount" to shift.initialAmount
            )
            val response = api.openSession(body)
            val remoteUuid = response["id"]?.toString() ?: response["sesionId"]?.toString()
            if (remoteUuid != null) {
                finalShift = shift.copy(remoteId = remoteUuid)
                Log.d("TacoSync", "✅ Sesión remota abierta: $remoteUuid")
            }
        } catch (e: Exception) {
            Log.e("TacoSync", "❌ Fallo al abrir sesión remota: ${e.message}")
        }
        return db.shiftDao().insertShift(finalShift)
    }
    
    suspend fun updateShift(shift: Shift) = db.shiftDao().updateShift(shift)

    // --- Ventas ---
    suspend fun registerSale(amount: Double, negocioId: String, userId: String, productsJson: String, method: String, imagePath: String?, shiftId: Long? = null) {
        db.saleDao().insertSale(Sale(0, amount, userId, productsJson, method, "ACTIVE", imagePath, System.currentTimeMillis(), false, negocioId, shiftId))
        syncPendingSales()
    }

    suspend fun getTodayTotal(): Double = db.saleDao().getTodayTotal(System.currentTimeMillis() - (System.currentTimeMillis() % 86400000L)) ?: 0.0

    suspend fun getSalesByRange(negocioId: String, start: Long, end: Long) = 
        db.saleDao().getSalesByRange(negocioId, start, end)

    // --- Gastos ---
    suspend fun registerExpense(id: String, detail: String, amount: Double, cashier: String, negocioId: String, imagePath: String?, shiftId: Long? = null) {
        db.expenseDao().insertExpense(
            Expense(
                id = id, 
                detail = detail, 
                amount = amount, 
                cashier = cashier, 
                timestamp = System.currentTimeMillis(), 
                imagePath = imagePath, 
                isSynced = false, 
                negocioId = negocioId,
                shiftId = shiftId
            )
        )
    }

    suspend fun getExpensesByRange(negocioId: String, start: Long, end: Long) = 
        db.expenseDao().getExpensesByRange(negocioId, start, end)

    // --- Analytics AI ---
    suspend fun getAiInsight(negocioId: String): AnalyticsReportResponse = api.getAiInsight(negocioId)

    // --- SINCRONIZACIÓN AUTOMÁTICA ---
    suspend fun syncPendingSales() {
        val pendingSales = db.saleDao().getAllSales().filter { !it.isSynced && it.status == "ACTIVE" }
        if (pendingSales.isEmpty()) return

        val user = getCurrentUser() ?: return
        val negocioId = user.negocioId ?: return
        
        pendingSales.forEach { sale ->
            try {
                // 1. Intentar encontrar turno vinculado
                var saleShift = sale.shiftId?.let { db.shiftDao().getShiftById(it) } 
                                ?: getActiveShift(negocioId)
                                ?: db.shiftDao().getShiftForTimestamp(negocioId, sale.timestamp)

                if (saleShift == null) {
                    Log.w("TacoSync", "⚠️ Venta ${sale.id} sin turno por fecha. Reintentando con turno activo global...")
                    saleShift = getActiveShift(negocioId)
                }

                if (saleShift == null) {
                    Log.w("TacoSync", "🚨 Venta ${sale.id} huérfana persistente. Creando turno de recuperación...")
                    val recoveryShift = Shift(
                        initialAmount = 0.0,
                        cashierName = "Recuperación Automática",
                        negocioId = negocioId,
                        openTimestamp = sale.timestamp - 1000,
                        status = "CLOSED",
                        closeTimestamp = sale.timestamp + 1000
                    )
                    val recoveryId = openShift(recoveryShift)
                    saleShift = db.shiftDao().getShiftById(recoveryId)
                }

                if (saleShift == null) {
                    Log.e("TacoSync", "❌ Imposible asociar venta ${sale.id} a un turno.")
                    return@forEach
                }

                // 4. Recuperación de sesión remota
                var sessionUuid = saleShift.remoteId
                if (sessionUuid == null) {
                    Log.d("TacoSync", "🔄 Abriendo sesión remota para turno ${saleShift.id}")
                    try {
                        val body = mapOf(
                            "business_id" to negocioId,
                            "cashier_id" to user.id,
                            "initial_amount" to saleShift.initialAmount
                        )
                        val response = api.openSession(body)
                        sessionUuid = response["id"]?.toString() ?: response["sesionId"]?.toString()
                        
                        if (sessionUuid != null) {
                            saleShift = saleShift.copy(remoteId = sessionUuid)
                            db.shiftDao().updateShift(saleShift)
                        }
                    } catch (e: Exception) {
                        Log.e("TacoSync", "❌ Error al abrir sesión remota: ${e.message}")
                    }
                }

                if (sessionUuid == null) {
                    Log.e("TacoSync", "⚠️ Saltando venta ${sale.id}: Sin UUID de sesión remota.")
                    return@forEach
                }

                // 5. Sincronizar
                val transactionData = mapOf(
                    "business_id" to negocioId,
                    "session_id" to sessionUuid,
                    "type" to "sale",
                    "cashier_id" to (if (sale.userId.isEmpty()) user.id else sale.userId),
                    "device_id" to "android-pos-v1",
                    "items" to sale.productsJson,
                    "payment" to mapOf(
                        "metodo" to sale.method.uppercase(),
                        "montoRecibido" to sale.amount,
                        "cambio" to 0.0
                    ),
                    "total" to sale.amount,
                    "description" to "Venta POS Android"
                )

                api.postTransaction(transactionData)
                db.saleDao().markAsSynced(sale.id)
                Log.d("TacoSync", "✅ Venta ${sale.id} sincronizada.")

            } catch (e: Exception) {
                Log.e("TacoSync", "❌ Error en sincronización: ${e.message}")
            }
        }
    }
}
