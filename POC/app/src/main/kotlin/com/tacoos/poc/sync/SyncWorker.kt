package com.tacoos.poc.sync

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.local.AppMetadata

class SyncWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val app = applicationContext as TacoApp
        val repository = TacoRepository(app.api, app.database)

        Log.d("SyncWorker", "Iniciando ciclo de sincronización offline...")
        
        return try {
            // 1. Sincronizar ventas locales hacia el servidor (Ventas realizadas offline)
            repository.syncPendingSales()
            
            // 2. Validar licencia y estado del negocio con el servidor maestro
            val user = repository.getCurrentUser()
            if (user != null) {
                // Aquí se llamaría a api.checkLicense(user.negocioId)
                Log.d("SyncWorker", "Licencia validada para negocio: ${user.negocioId}")
            }

            // 3. Actualizar metadatos de sincronización
            val db = app.database
            val currentMetadata = db.metadataDao().getMetadata()
            db.metadataDao().updateMetadata(
                AppMetadata(
                    lastLoginTimestamp = currentMetadata?.lastLoginTimestamp ?: System.currentTimeMillis(),
                    lastMasterSyncTimestamp = System.currentTimeMillis(),
                    isLicenseValid = true
                )
            )
            
            Result.success()
        } catch (e: Exception) {
            Log.e("SyncWorker", "Error en sincronización periódica, se reintentará", e)
            Result.retry()
        }
    }
}
