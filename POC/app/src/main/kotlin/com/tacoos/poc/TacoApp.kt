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
import java.util.concurrent.TimeUnit

class TacoApp : Application() {
    lateinit var database: AppDatabase
    lateinit var api: TacoApi

    override fun onCreate() {
        super.onCreate()
        database = Room.databaseBuilder(this, AppDatabase::class.java, "taco-db")
            .fallbackToDestructiveMigration()
            .build()

        val client = OkHttpClient.Builder()
            .addInterceptor { chain ->
                val requestBuilder = chain.request().newBuilder()
                if (GoogleSignInState.token.isNotEmpty()) {
                    requestBuilder.addHeader("Authorization", "Bearer ${GoogleSignInState.token}")
                }
                chain.proceed(requestBuilder.build())
            }
            .build()

        val retrofit = Retrofit.Builder()
            .baseUrl(TacoApi.BASE_URL) 
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        api = retrofit.create(TacoApi::class.java)

        // Configuración de Sincronización Offline (Cada 15 min - Mínimo permitido por Android)
        setupSyncWorker()
    }

    private fun setupSyncWorker() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED) // Solo sincroniza con internet
            .build()

        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "TacoSync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )
    }
}
