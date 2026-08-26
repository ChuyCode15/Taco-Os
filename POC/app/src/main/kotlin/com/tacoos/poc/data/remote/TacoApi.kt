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
    suspend fun verifyUser(@Path("idGoogle") idGoogle: String): AuthResponse

    /** Registra un nuevo usuario en el sistema. */
    @POST("api/v1/auth/registrar")
    suspend fun registerUser(@Body request: RegisterRequest): AuthResponse

    /** Renueva el token de acceso utilizando un token de refresco. */
    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Body body: Map<String, String>): Map<String, String>

    // --- NEGOCIO ---
    /** Crea un nuevo negocio para el dueño especificado. */
    @POST("api/v1/business")
    suspend fun createBusiness(
        @Query("duenoId") duenoId: String,
        @Body request: BusinessRequest
    ): BusinessResponse

    /** Obtiene los detalles de un negocio por su ID. */
    @GET("api/v1/business/{id}")
    suspend fun getBusiness(@Path("id") id: UUID): BusinessResponse

    /** Actualiza la información de un negocio existente. */
    @PUT("api/v1/business/{id}")
    suspend fun updateBusiness(@Path("id") id: UUID, @Body request: BusinessRequest): BusinessResponse

    /** Lista los cajeros de un negocio determinado. */
    @GET("api/v1/business/{id}/cajeros")
    suspend fun getCashiers(@Path("id") id: String): DatosListaCajeros

    // --- ENLACE ---
    /** Genera un código de invitación para un nuevo cajero. */
    @POST("api/v1/business/invitation")
    suspend fun generateInvitation(@Body request: InvitationRequest): InvitationResponse

    /** Enlaza a un cajero con un negocio mediante invitación. */
    @POST("api/v1/business/link")
    suspend fun linkCashier(@Body request: LinkRequest): LinkResponse

    // --- PRODUCTOS ---
    /** Crea un nuevo producto dentro de un negocio. */
    @POST("api/v1/business/{id}/products")
    suspend fun createProduct(
        @Path("id") id: UUID, 
        @Body product: @JvmSuppressWildcards Map<String, Any>
    ): Map<String, Any>

    /** Obtiene la lista de productos de un negocio. */
    @GET("api/v1/business/{id}/products")
    suspend fun getProducts(@Path("id") id: UUID): List<Map<String, Any>>

    // --- ANALYTICS AI ---
    /** Genera un reporte de inteligencia artificial para el negocio. */
    @GET("api/v1/analytics/report/{negocioId}")
    suspend fun getAiInsight(@Path("negocioId") negocioId: String): AnalyticsReportResponse

    // --- CAJA & TRANSACCIONES ---
    /** Abre una sesión de caja para empezar a vender. */
    @POST("api/v1/cashier/open-session")
    suspend fun openSession(@Body body: @JvmSuppressWildcards Map<String, Any>): Map<String, Any>

    /** Cierra la sesión de caja actual. */
    @POST("api/v1/cashier/close-session")
    suspend fun closeSession(@Body body: @JvmSuppressWildcards Map<String, Any>): Map<String, Any>

    /** Registra una nueva transacción de venta. */
    @POST("api/v1/transactions")
    suspend fun postTransaction(@Body body: @JvmSuppressWildcards Map<String, Any>): Map<String, Any>

    // --- LICENCIA & REPORTES ---
    /** Consulta el estado de la licencia del negocio. */
    @GET("api/v1/business/{negocioId}/license")
    suspend fun getLicenseStatus(@Path("negocioId") negocioId: UUID): Map<String, Any>

    /** Sincroniza un lote de datos locales con el servidor. */
    @POST("api/v1/sync")
    suspend fun syncBatch(@Body data: @JvmSuppressWildcards Map<String, Any>): Map<String, Any>

    /** Comprueba la disponibilidad del servidor. */
    @GET("api/v1/health")
    suspend fun checkHealth(): Map<String, String>
    
    companion object {
        /** URL base del servidor de API. */
        const val BASE_URL = "http://10.0.2.2:8080/"
    }
}
