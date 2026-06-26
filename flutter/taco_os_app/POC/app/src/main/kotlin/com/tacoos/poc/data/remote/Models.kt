package com.tacoos.poc.data.remote

import java.util.UUID

// Auth Models
data class AuthResponse(
    val id: UUID? = null,
    val idGoogle: String,
    val nombre: String?,
    val email: String?,
    val rol: String?,
    val existe: Boolean = true,
    val codigo: String? = null,
    val mensaje: String? = null
)

data class RegisterRequest(
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val fotoUrl: String?,
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
