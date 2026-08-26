package com.tacoos.poc.data.remote.dto

import kotlinx.serialization.Serializable

/** Respuesta genérica de autenticación. */
@Serializable
data class AuthResponse(
    val success: Boolean,
    val message: String?,
    val data: AuthData? = null
)

/** Datos de usuario dentro de una respuesta de autenticación. */
@Serializable
data class AuthData(
    val id: String,
    val email: String,
    val name: String
)

/** Solicitud para registrar a un usuario manualmente. */
@Serializable
data class RegisterRequest(
    val email: String,
    val name: String,
    val idGoogle: String
)

/** Solicitud para crear un nuevo negocio. */
@Serializable
data class BusinessRequest(
    val name: String,
    val address: String
)

/** Respuesta con información básica de un negocio. */
@Serializable
data class BusinessResponse(
    val id: String,
    val name: String
)

/** Solicitud para generar una invitación a un negocio. */
@Serializable
data class InvitationRequest(
    val email: String
)

/** Respuesta que contiene el código de invitación generado. */
@Serializable
data class InvitationResponse(
    val code: String
)

/** Solicitud para enlazar a un cajero mediante un código. */
@Serializable
data class LinkRequest(
    val invitationCode: String
)

/** Respuesta indicando el éxito o fallo del enlace. */
@Serializable
data class LinkResponse(
    val success: Boolean
)

/** Respuesta que contiene los hallazgos de analítica IA. */
@Serializable
data class AnalyticsReportResponse(
    val insight: String
)

/** Envoltorio para una lista de cajeros. */
@Serializable
data class DatosListaCajeros(
    val cajeros: List<String>
)
