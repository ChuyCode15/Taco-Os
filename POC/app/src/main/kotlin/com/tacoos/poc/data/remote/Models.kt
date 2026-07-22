package com.tacoos.poc.data.remote

import java.util.UUID

// Auth Models
data class AuthResponse(
    val existe: Boolean,
    val token: String? = null,
    val vencimiento: Int? = null,
    val usuario: DatosUsuarioAuth? = null,
    val mensaje: String? = null
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

// --- Sync Models ---

data class SyncBatchRequest(
    val userEmail: String, // Identificador simple para el POC
    val shifts: List<Map<String, Any>> = emptyList(),
    val sales: List<Map<String, Any>> = emptyList()
)
