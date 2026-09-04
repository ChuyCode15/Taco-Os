package com.tacoos.poc.di

import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import com.tacoos.poc.BuildConfig
import com.tacoos.poc.data.remote.AuthApiService
import com.tacoos.poc.data.remote.AuthInterceptor
import com.tacoos.poc.data.remote.BusinessApiService
import com.tacoos.poc.data.remote.TacoApi
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import javax.inject.Singleton

/**
 * Módulo de Hilt encargado de configurar la infraestructura de red, incluyendo
 * Retrofit, OkHttp y los servicios de API.
 */
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    /** Configura el serializador JSON de Kotlinx. */
    @Provides
    @Singleton
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        isLenient = true
    }

    /** 
     * Configura el cliente HTTP con interceptores de autenticación y logging.
     * 
     * Seguridad aplicada:
     * - **Nivel de Log dinámico:** Solo muestra el cuerpo de las peticiones en modo DEBUG. En RELEASE se desactiva.
     * - **Redacción de cabeceras:** Se oculta el valor del encabezado 'Authorization' en los logs para evitar fugas accidental de tokens.
     */
    @Provides
    @Singleton
    fun provideOkHttpClient(
        authInterceptor: AuthInterceptor
    ): OkHttpClient {
        val logging = HttpLoggingInterceptor().apply {
            // Solo logueamos el cuerpo en modo DEBUG
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
            
            // Redactar encabezado sensible por seguridad adicional
            redactHeader("Authorization")
        }
        
        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(logging)
            .build()
    }

    /** Crea la instancia de Retrofit configurada con la URL base y el convertidor JSON. */
    @Provides
    @Singleton
    fun provideRetrofit(json: Json, okHttpClient: OkHttpClient): Retrofit {
        val contentType = "application/json".toMediaType()
        return Retrofit.Builder()
            .baseUrl("http://10.0.2.2:8080/")
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory(contentType))
            .build()
    }

    /** Proporciona el servicio de autenticación. */
    @Provides
    @Singleton
    fun provideAuthApiService(retrofit: Retrofit): AuthApiService {
        return retrofit.create(AuthApiService::class.java)
    }

    /** Proporciona el servicio de gestión de negocios. */
    @Provides
    @Singleton
    fun provideBusinessApiService(retrofit: Retrofit): BusinessApiService {
        return retrofit.create(BusinessApiService::class.java)
    }

    /** Proporciona la interfaz unificada de TacoApi. */
    @Provides
    @Singleton
    fun provideTacoApi(retrofit: Retrofit): TacoApi {
        return retrofit.create(TacoApi::class.java)
    }
}
