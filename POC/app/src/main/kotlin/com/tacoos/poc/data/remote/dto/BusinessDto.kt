package com.tacoos.poc.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Datos requeridos para registrar un nuevo negocio en el servidor.
 */
@Serializable
data class DatosRegistroNegocio(
    @SerialName("nombre") val nombre: String,
    @SerialName("direccion") val direccion: String,
    @SerialName("telefono") val telefono: String,
    @SerialName("queVende") val giro: String,
    @SerialName("empleados") val empleados: Int,
    @SerialName("horario") val horarioCierre: String
)

/**
 * Detalles completos de un negocio devueltos por la API.
 */
@Serializable
data class DatosDetalleNegocio(
    @SerialName("id") val id: String,
    @SerialName("nombre") val nombre: String,
    @SerialName("direccion") val direccion: String,
    @SerialName("telefono") val telefono: String,
    @SerialName("queVende") val giro: String,
    @SerialName("empleados") val empleados: Int,
    @SerialName("horario") val horarioCierre: String,
    @SerialName("creadoEl") val registro: String
)
