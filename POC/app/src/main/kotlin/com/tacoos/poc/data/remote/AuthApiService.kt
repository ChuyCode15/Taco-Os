package com.tacoos.poc.data.remote

import com.tacoos.poc.data.remote.dto.DatosRegistroAuth
import com.tacoos.poc.data.remote.dto.DatosRespuestaAuth
import com.tacoos.poc.data.remote.dto.DatosVerificarAuth
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

/**
 * Servicio que define los puntos finales para las operaciones de autenticación en la API remota.
 */
interface AuthApiService {

    /**
     * Comprueba la existencia de un usuario en el sistema a través de su identificador de Google.
     * @param idGoogle Identificador único proporcionado por Google.
     * @return Datos de verificación del usuario.
     */
    @GET("api/v1/auth/verificar/{idGoogle}")
    suspend fun verifyUser(
        @Path("idGoogle") idGoogle: String
    ): DatosVerificarAuth

    /**
     * Registra a un nuevo usuario en la plataforma con los datos proporcionados.
     * @param request Información necesaria para el registro del usuario.
     * @return Respuesta que contiene los datos del usuario registrado y tokens de sesión.
     */
    @POST("api/v1/auth/registrar")
    suspend fun registerUser(
        @Body request: DatosRegistroAuth
    ): DatosRespuestaAuth
}
