package com.tacoos.poc.data.remote

import com.tacoos.poc.data.remote.dto.DatosDetalleNegocio
import com.tacoos.poc.data.remote.dto.DatosListaCajeros
import com.tacoos.poc.data.remote.dto.DatosRegistroNegocio
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path
import retrofit2.http.Query

/**
 * Servicio de red para gestionar las operaciones relacionadas con negocios y cajeros.
 */
interface BusinessApiService {

    /**
     * Crea un nuevo registro de negocio en el sistema vinculado a un usuario propietario.
     * @param request Datos del negocio a registrar.
     * @param duenoId Identificador del usuario que será el dueño del negocio.
     * @return Detalles del negocio recién creado.
     */
    @POST("api/v1/business")
    suspend fun registerBusiness(
        @Body request: DatosRegistroNegocio,
        @Query("duenoId") duenoId: String
    ): DatosDetalleNegocio

    /**
     * Recupera el listado de cajeros que pertenecen a un negocio específico.
     * @param businessId Identificador único del negocio.
     * @return Lista de cajeros asociados.
     */
    @GET("api/v1/business/{id}/cajeros")
    suspend fun getCajeros(
        @Path("id") businessId: String
    ): DatosListaCajeros
}
