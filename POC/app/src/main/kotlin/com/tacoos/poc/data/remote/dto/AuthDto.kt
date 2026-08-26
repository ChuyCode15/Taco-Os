package com.tacoos.poc.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Datos necesarios para registrar a un nuevo usuario en el sistema.
 */
@Serializable
data class DatosRegistroAuth(
    @SerialName("idGoogle") val idGoogle: String,
    @SerialName("nickname") val nickname: String,
    @SerialName("correo") val correo: String,
    @SerialName("numero") val numero: String? = null,
    @SerialName("rol") val rol: String = "dueño"
)

/**
 * Representa la respuesta del servidor al intentar verificar la existencia de un usuario.
 */
@Serializable
data class DatosVerificarAuth(
    @SerialName("existe") val existe: Boolean,
    @SerialName("token") val token: String? = null,
    @SerialName("vencimiento") val vencimiento: Int? = null,
    @SerialName("usuario") val usuario: DatosUsuarioAuth? = null,
    @SerialName("codigo") val codigo: String? = null,
    @SerialName("mensaje") val mensaje: String? = null
)

/**
 * Respuesta recibida tras un proceso de registro exitoso.
 */
@Serializable
data class DatosRespuestaAuth(
    @SerialName("token") val token: String,
    @SerialName("vencimiento") val vencimiento: Int,
    @SerialName("usuario") val usuario: DatosUsuarioAuth
)

/**
 * Información detallada del perfil del usuario según el backend.
 */
@Serializable
data class DatosUsuarioAuth(
    @SerialName("id") val id: String,
    @SerialName("idGoogle") val idGoogle: String,
    @SerialName("nickname") val nickname: String,
    @SerialName("correo") val correo: String,
    @SerialName("rol") val rol: String,
    @SerialName("tieneNegocio") val tieneNegocio: Boolean,
    @SerialName("negocioId") val negocioId: String? = null,
    @SerialName("negocioNombre") val negocioNombre: String? = null
)

/**
 * Objeto para capturar y procesar errores específicos devueltos por la API.
 */
@Serializable
data class BackendErrorDto(
    @SerialName("error") val error: String? = null,
    @SerialName("mensaje") val mensaje: String? = null,
    @SerialName("ubicacion") val ubicacion: String? = null
)

/**
 * Solicitud que contiene el token de identidad de Google para autenticación.
 */
@Serializable
data class GoogleAuthRequestDto(
    @SerialName("idToken") val idToken: String
)
