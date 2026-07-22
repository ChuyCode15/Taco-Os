package com.tacoos.poc

import android.app.Application
import androidx.room.Room
import androidx.work.*
import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.remote.TacoApi
import com.tacoos.poc.sync.SyncWorker
import com.tacoos.poc.ui.screens.GoogleSignInState
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.sync.SyncWorker
import java.util.concurrent.TimeUnit

/**
 * TacoApp: Clase base de la aplicación que gestiona el ciclo de vida global y la inyección de dependencias.
 * Propósito: Inicializar componentes críticos como Room, Retrofit y WorkManager al arrancar el proceso.
 */
class TacoApp : Application() {

    // Inyección de dependencias de acceso global (manual).
    lateinit var database: AppDatabase
    lateinit var api: TacoApi
    lateinit var repository: TacoRepository

    override fun onCreate() {
        super.onCreate()
        
        // Inicialización de la Base de Datos Local (SQLite vía Room).
        database = Room.databaseBuilder(
            this,
            AppDatabase::class.java, "taco-db"
        ).fallbackToDestructiveMigration().build()

        // Configuración de OkHttpClient con Interceptor de Seguridad.
        val client = OkHttpClient.Builder()
            .addInterceptor { chain ->
                val requestBuilder = chain.request().newBuilder()
                // Inyección dinámica del Token JWT en cada petición saliente.
                if (GoogleSignInState.token.isNotEmpty()) {
                    requestBuilder.addHeader("Authorization", "Bearer ${GoogleSignInState.token}")
                }
                chain.proceed(requestBuilder.build())
            }
            .build()

        // Inicialización de la Capa de Red (Retrofit).
        api = Retrofit.Builder()
            .baseUrl(TacoApi.BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()


        // Inicialización del Repositorio Único.
        repository = TacoRepository(api, database)

        // Lanzamiento del motor de sincronización asíncrona.
        setupPeriodicSync()
    }

    /**
     * setupPeriodicSync: Configura una tarea de fondo (WorkManager) para subir ventas locales al servidor.
     * Frecuencia: Cada 15 minutos (mínimo permitido por Android para ahorro de batería).
     */
    private fun setupPeriodicSync() {
        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
            .setInitialDelay(5, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "TacoSync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )
    }
}
