package com.tacoos.poc.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Datos para la apertura de una sesión de caja.
 */
@Serializable
data class DatosAperturaSesion(
    @SerialName("negocio_id") val negocioId: String,
    @SerialName("cajero_id") val cajeroId: String,
    @SerialName("dispositivo_id") val dispositivoId: String,
    @SerialName("fondo_apertura") val fondoApertura: Double
)

/**
 * Datos para el cierre de una sesión y realización del corte.
 */
@Serializable
data class DatosCierreSesion(
    @SerialName("sesion_id") val sesionId: String,
    @SerialName("efectivo_real") val efectivoReal: Double,
    @SerialName("notas") val notas: String? = null
)

/**
 * Respuesta del servidor tras procesar un corte de caja.
 */
@Serializable
data class DatosRespuestaCorte(
    @SerialName("id") val id: String,
    @SerialName("total_ventas") val totalVentas: Double,
    @SerialName("total_gastos") val totalGastos: Double,
    @SerialName("efectivo_esperado") val efectivoEsperado: Double,
    @SerialName("diferencia") val diferencia: Double,
    @SerialName("cierre") val fechaCierre: String,
    @SerialName("ticket_url") val ticketUrl: String? = null
)

/**
 * Representa un item de gasto para ser registrado.
 */
@Serializable
data class GastoItemDto(
    @SerialName("categoria") val categoria: String,
    @SerialName("monto") val monto: Double
)

/**
 * Representa un item de venta para ser registrado.
 */
@Serializable
data class VentaItemDto(
    @SerialName("producto_id") val productoId: String,
    @SerialName("cantidad") val cantidad: Int,
    @SerialName("subtotal") val subtotal: Double
)

/**
 * Estructura de pago para una transacción.
 */
@Serializable
data class DatosPago(
    @SerialName("metodo") val metodo: String,
    @SerialName("monto_recibido") val montoRecibido: Double? = null,
    @SerialName("referencia") val referencia: String? = null
)

/**
 * Registro completo de una transacción (Venta o Gasto).
 */
@Serializable
data class DatosRegistroTransaccion(
    @SerialName("business_id") val negocioId: String,
    @SerialName("session_id") val sesionId: String,
    @SerialName("type") val tipo: String, // SALE, EXPENSE
    @SerialName("cashier_id") val cajeroId: String,
    @SerialName("device_id") val dispositivoId: String,
    @SerialName("payment") val pago: DatosPago,
    @SerialName("total") val total: Double,
    @SerialName("description") val descripcion: String? = null,
    @SerialName("sales") val ventas: List<VentaItemDto>? = null,
    @SerialName("expenses") val gastos: List<GastoItemDto>? = null
)

/**
 * Respuesta del servidor tras registrar una transacción.
 */
@Serializable
data class DatosRespuestaTransaccion(
    @SerialName("id") val id: String,
    @SerialName("status") val estado: String,
    @SerialName("timestamp") val fecha: String
)

/**
 * Datos para registrar un nuevo producto.
 */
@Serializable
data class DatosRegistroProducto(
    @SerialName("name") val nombre: String,
    @SerialName("price") val precio: Double,
    @SerialName("category") val categoria: String,
    @SerialName("imagePath") val imagenUrl: String? = null
)

/**
 * Representa el estado de la licencia de un negocio.
 */
@Serializable
data class DatosLicencia(
    @SerialName("negocio_id") val negocioId: String,
    @SerialName("estado") val estado: String,
    @SerialName("fecha_vencimiento") val fechaVencimiento: String,
    @SerialName("plan") val plan: String
)
