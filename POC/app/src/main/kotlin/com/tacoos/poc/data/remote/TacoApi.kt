package com.tacoos.poc.data.remote

import retrofit2.http.*
import java.util.UUID

interface TacoApi {
    
    // --- AUTH (B) ---
    @GET("api/v1/auth/verificar/{idGoogle}")
    suspend fun verifyUser(@Path("idGoogle") idGoogle: String): AuthResponse

    @POST("api/v1/auth/registrar")
    suspend fun registerUser(@Body request: RegisterRequest): AuthResponse

    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Body body: Map<String, String>): Map<String, String>

    // --- NEGOCIO (C) ---
    @POST("api/v1/business")
    suspend fun createBusiness(
        @Query("duenoId") duenoId: String,
        @Body request: BusinessRequest
    ): BusinessResponse

    @GET("api/v1/business/{id}")
    suspend fun getBusiness(@Path("id") id: UUID): BusinessResponse

    @PUT("api/v1/business/{id}")
    suspend fun updateBusiness(@Path("id") id: UUID, @Body request: BusinessRequest): BusinessResponse

    @GET("api/v1/business/{id}/cajeros")
    suspend fun getCashiers(@Path("id") id: UUID): List<AuthResponse>

    // --- ENLACE (D) ---
    @POST("api/v1/business/invitation")
    suspend fun generateInvitation(@Body request: InvitationRequest): InvitationResponse

    @POST("api/v1/business/link")
    suspend fun linkCashier(@Body request: LinkRequest): LinkResponse

    // --- PRODUCTOS ---
    @POST("api/v1/business/{id}/products")
    suspend fun createProduct(@Path("id") id: UUID, @Body product: Map<String, Any>): Map<String, Any>

    @GET("api/v1/business/{id}/products")
    suspend fun getProducts(@Path("id") id: UUID): List<Map<String, Any>>

    // --- CAJA & TRANSACCIONES ---
    @POST("api/v1/cashier/open-session")
    suspend fun openSession(@Body body: Map<String, Any>): Map<String, Any>

    @POST("api/v1/cashier/close-session")
    suspend fun closeSession(@Body body: Map<String, Any>): Map<String, Any>

    @POST("api/v1/transactions")
    suspend fun postTransaction(@Body body: Map<String, Any>): Map<String, Any>

    // --- LICENCIA & REPORTES ---
    @GET("api/v1/business/{negocioId}/license")
    suspend fun getLicenseStatus(@Path("negocioId") negocioId: UUID): Map<String, Any>

    @POST("api/v1/sync")
    suspend fun syncBatch(@Body data: Map<String, Any>): Map<String, Any>

    @GET("api/v1/health")
    suspend fun checkHealth(): Map<String, String>
    
    companion object {
        //const val BASE_URL = "http://192.168.1.144:8080/"
        const val BASE_URL = "http://192.168.1.7:8080/"
        //const val BASE_URL = "http://10.0.2.2:8080/"
    }
}
