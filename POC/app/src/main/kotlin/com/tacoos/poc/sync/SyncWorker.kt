package com.tacoos.poc.sync

import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.local.*
import com.tacoos.poc.data.remote.*
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.io.File
import okhttp3.MediaType
import okhttp3.RequestBody

class SyncWorker(
    appContext: android.content.Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    private suspend fun uploadFile(api: TacoApi, path: String?, type: String): String? {
        if (path.isNullOrEmpty()) return null
        val file = File(path)
        if (!file.exists()) return null
        
        return try {
            val mediaType = MediaType.parse("image/jpeg")
            val requestFile = RequestBody.create(mediaType, file)
            val typeBody = RequestBody.create(MediaType.parse("text/plain"), type)
            val response = api.uploadPhoto(requestFile, typeBody)
            response["url"]
        } catch (e: Exception) {
            Log.e("SyncWorker", "Error subiendo foto $path: ${e.message}")
            null
        }
    }

    override suspend fun doWork(): Result {
        val app = applicationContext as TacoApp
        val db = app.database
        val api = app.api

        Log.d("SyncWorker", "Iniciando ciclo de sincronización...")
        
        return try {
            val user = db.userDao().getCurrentUser() ?: return Result.success()
            val tenantId = user.tenantId
            val userId = user.id

            // 1. Recolectar datos pendientes
            val pendingShifts = db.shiftDao().getPendingShifts()
            
            val pendingNotes = db.saleDao().getPendingNotes()
            val saleNoteDtos = mutableListOf<SaleNoteDto>()
            for (note in pendingNotes) {
                val details = db.saleDao().getDetailsByNote(note.id).map {
                    SaleDetailDto(it.id, it.productName, it.quantity, it.unitPrice, it.subtotal)
                }
                saleNoteDtos.add(
                    SaleNoteDto(
                        note.id, note.shiftId, note.businessId, note.cashierId, note.tenantId,
                        note.customerName, note.totalAmount, note.paymentMethod, note.timestamp,
                        note.isCancelled, details
                    )
                )
            }

            val pendingExpenses = db.expenseDao().getPendingExpenses()
            val expenseDtos = mutableListOf<ExpenseDto>()
            for (exp in pendingExpenses) {
                val url = uploadFile(api, exp.photoPath, "expense")
                expenseDtos.add(
                    ExpenseDto(exp.id, exp.shiftId, exp.cashierId, exp.businessId, exp.tenantId, 
                               exp.description, exp.amount, url ?: exp.photoPath, exp.timestamp)
                )
            }

            val pendingCancellations = db.cancellationDao().getPendingCancellations()
            val cancellationDtos = mutableListOf<CancellationDto>()
            for (can in pendingCancellations) {
                val url = uploadFile(api, can.photoPath, "cancellation")
                cancellationDtos.add(
                    CancellationDto(can.id, can.noteId, can.shiftId, can.cashierId, can.reason, 
                                    url ?: can.photoPath, can.timestamp)
                )
            }

            // 2. Enviar Batch
            if (pendingShifts.isNotEmpty() || saleNoteDtos.isNotEmpty() || 
                expenseDtos.isNotEmpty() || cancellationDtos.isNotEmpty()) {
                
                val request = SyncBatchRequest(
                    tenantId = tenantId,
                    userId = userId,
                    shifts = pendingShifts.map { s ->
                        ShiftDto(s.id, s.businessId, s.cashierId, s.tenantId, s.openTimestamp, 
                                s.closeTimestamp, s.initialCash, s.totalSales, s.totalExpenses, 
                                s.totalCancellations, s.totalCash, s.totalCard, s.comment) 
                    },
                    sales = saleNoteDtos,
                    expenses = expenseDtos,
                    cancellations = cancellationDtos
                )

                api.syncBatch(request)

                // 3. Marcar como sincronizados localmente
                pendingShifts.forEach { db.shiftDao().updateShift(it.copy(isSynced = true)) }
                pendingNotes.forEach { db.saleDao().updateNote(it.copy(isSynced = true)) }
                pendingExpenses.forEach { db.expenseDao().updateExpense(it.copy(isSynced = true)) }
            }

            // 4. Pruning (Limpieza cada 24 horas)
            val threshold = System.currentTimeMillis() - (24 * 60 * 60 * 1000)
            db.shiftDao().pruneSyncedShifts(threshold)
            db.saleDao().pruneSyncedSales(threshold)
            db.expenseDao().pruneSyncedExpenses(threshold)

            Log.d("SyncWorker", "Sincronización completada.")
            Result.success()
        } catch (e: Exception) {
            Log.e("SyncWorker", "Error en sincronización: ${e.message}")
            Result.retry()
        }
    }
}
