package com.tacoos.poc.data.remote

import java.util.UUID

// Auth Models
data class AuthResponse(
    val existe: Boolean,
    val token: String? = null,
    val vencimiento: Int? = null,
    val usuario: DatosUsuarioAuth? = null,
    val mensaje: String? = null // Para errores
)

data class DatosUsuarioAuth(
    val id: String,
    val idGoogle: String,
    val nickname: String?,
    val correo: String?,
    val rol: String?,
    val tieneNegocio: Boolean = false,
    val negocioId: String? = null,
    val negocioNombre: String? = null
)

data class RegisterRequest(
    val idGoogle: String,
    val nickname: String,
    val correo: String,
    val numero: String? = null,
    val rol: String // "dueño" o "cajero"
)

// Business Models
data class BusinessRequest(
    val nombre: String,
    val direccion: String,
    val telefono: String,
    val queVende: String? = null,
    val empleados: Int? = null,
    val horarioCierre: String? = null
)

data class BusinessResponse(
    val id: UUID,
    val nombre: String,
    val direccion: String,
    val telefono: String,
    val moneda: String = "MXN",
    val dineroBase: Double = 0.0
)

// Cajero Models
data class DatosListaCajeros(
    val lista: List<CajeroResponse>? = emptyList()
)

data class CajeroResponse(
    val id: String,
    val idGoogle: String,
    val nombreCompleto: String,
    val nickname: String?,
    val correo: String,
    val numero: String?,
    val permisos: String?,
    val fechaEnlace: String?,
    val activo: Boolean
)

// Sale Sync Models
data class SaleRequest(
    val amount: Double,
    val productsJson: String,
    val userId: String,
    val timestamp: Long,
    val status: String = "ACTIVE"
)

// Linking Models
data class InvitationRequest(
    val negocioId: UUID,
    val duenoId: UUID
)

data class InvitationResponse(
    val codigo: String,
    val expiraEnMinutos: Int,
    val qrPayload: String
)

data class LinkRequest(
    val codigo: String,
    val usuarioId: UUID
)

data class LinkResponse(
    val enlazado: Boolean,
    val negocioId: UUID?,
    val nombre: String?,
    val direccion: String?,
    val moneda: String?,
    val dineroBase: Double?
)
