package com.tacoos.poc.data.remote

import com.tacoos.poc.data.remote.dto.*
import retrofit2.http.*
import java.util.UUID

/**
 * Interfaz principal que define todos los endpoints de la API de Taco'OS.
 * Proporciona métodos para autenticación, gestión de negocios, productos, analítica y transacciones.
 */
interface TacoApi {
    
    // --- AUTH ---
    /** Verifica la existencia de un usuario mediante Google ID. */
    @GET("api/v1/auth/verificar/{idGoogle}")
    suspend fun verifyUser(@Path("idGoogle") idGoogle: String): DatosVerificarAuth

    /** Registra un nuevo usuario en el sistema. */
    @POST("api/v1/auth/registrar")
    suspend fun registerUser(@Body request: DatosRegistroAuth): DatosRespuestaAuth

    // --- SESIONES Y CORTE ---
    /** Abre una sesión de caja. */
    @POST("api/v1/cashier/open-session")
    suspend fun openSession(@Body request: DatosAperturaSesion): Map<String, String>

    /** Cierra la sesión de caja y genera el corte. */
    @POST("api/v1/cashier/close-session")
    suspend fun closeSession(@Body request: DatosCierreSesion): DatosRespuestaCorte

    // --- NEGOCIO ---
    /** Crea un nuevo negocio para el dueño especificado. */
    @POST("api/v1/business")
    suspend fun createBusiness(
        @Query("duenoId") duenoId: String,
        @Body request: BusinessRequest
    ): BusinessResponse

    // --- TRANSACCIONES (VENTAS Y GASTOS) ---
    /** Registra una nueva transacción (Venta o Gasto). */
    @POST("api/v1/transactions")
    suspend fun postTransaction(@Body request: DatosRegistroTransaccion): DatosRespuestaTransaccion

    // --- PRODUCTOS ---
    /** Crea un nuevo producto dentro de un negocio. */
    @POST("api/v1/business/{id}/products")
    suspend fun createProduct(
        @Path("id") id: UUID, 
        @Body product: DatosRegistroProducto
    ): Map<String, Any>

    // --- ANALYTICS & LICENCIA ---
    /** Genera un reporte de inteligencia artificial para el negocio. */
    @GET("api/v1/analytics/report/{negocioId}")
    suspend fun getAiInsight(@Path("negocioId") negocioId: String): AnalyticsReportResponse

    /** Consulta el estado de la licencia del negocio. */
    @GET("api/v1/business/{negocioId}/license")
    suspend fun getLicenseStatus(@Path("negocioId") negocioId: String): DatosLicencia

    // --- OTROS ---
    /** Comprueba la disponibilidad del servidor. */
    @GET("api/v1/health")
    suspend fun checkHealth(): Map<String, String>
    
    companion object {
        /** URL base del servidor de API. */
        const val BASE_URL = "http://10.0.2.2:8080/"
    }
}

