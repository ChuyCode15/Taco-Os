package com.tacoos.poc

import android.app.Application
import androidx.room.Room
import com.tacoos.poc.data.local.AppDatabase
import com.tacoos.poc.data.remote.TacoApi
import com.tacoos.poc.ui.screens.GoogleSignInState
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.tacoos.poc.sync.SyncWorker
import java.util.concurrent.TimeUnit

class TacoApp : Application() {
    
    lateinit var database: AppDatabase
    lateinit var api: TacoApi

    override fun onCreate() {
        super.onCreate()
        
        database = Room.databaseBuilder(
            this,
            AppDatabase::class.java, "taco-db"
        ).fallbackToDestructiveMigration().build()

        val client = OkHttpClient.Builder()
            .addInterceptor { chain ->
                val requestBuilder = chain.request().newBuilder()
                if (GoogleSignInState.token.isNotEmpty()) {
                    requestBuilder.addHeader("Authorization", "Bearer ${GoogleSignInState.token}")
                }
                chain.proceed(requestBuilder.build())
            }
            .build()

        api = Retrofit.Builder()
            .baseUrl(TacoApi.BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(TacoApi::class.java)

        setupPeriodicSync()
    }

    private fun setupPeriodicSync() {
        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES) // Mínimo permitido por Android
            .setInitialDelay(5, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "TacoSync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )
    }
}
