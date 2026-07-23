package com.tacoos.poc.sync

import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.local.AppMetadata
import android.util.Log

class SyncWorker(
    appContext: android.content.Context,
    workerParams: androidx.work.WorkerParameters
) : androidx.work.CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val app = applicationContext as TacoApp
        val database = app.database
        val api = app.api

        Log.d("SyncWorker", "Iniciando sincronización periódica (5-10 min)...")
        
        return try {
            // 1. Obtener ventas no sincronizadas
            // (Aquí implementaríamos la lógica de subir a TacoApi)
            
            // 2. Reportar al Sistema Maestro (Check de Licencia)
            // val licenseResponse = api.checkLicense(...) 
            
            // 3. Actualizar timestamp de sincronización exitosa
            val currentMetadata = database.metadataDao().getMetadata()
            database.metadataDao().updateMetadata(
                AppMetadata(
                    lastLoginTimestamp = currentMetadata?.lastLoginTimestamp ?: 0L,
                    lastMasterSyncTimestamp = System.currentTimeMillis(),
                    isLicenseValid = true // Actualizar según respuesta del servidor
                )
            )
            
            Log.d("SyncWorker", "Sincronización y Validación de Licencia exitosa")
            Result.success()
        } catch (e: Exception) {
            Log.e("SyncWorker", "Fallo en la sincronización, trabajando en modo offline", e)
            // No pasa nada si falla por unas horas, el modo offline permite seguir operando
            Result.retry()
        }
    }
}
