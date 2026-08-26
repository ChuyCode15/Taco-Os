package com.tacoos.poc.domain.model

/**
 * Modelo de dominio que representa a un usuario dentro del ecosistema Taco'OS.
 * Esta clase es agnóstica a la implementación de datos y frameworks.
 * @property id Identificador único del sistema.
 * @property idGoogle Identificador de la cuenta de Google.
 * @property nickname Apodo o nombre de usuario.
 * @property email Dirección de correo electrónico.
 * @property rol Permisos asignados al usuario (ej. dueño, cajero).
 * @property tieneNegocio Indica si el usuario ya tiene un negocio registrado.
 * @property negocioId Identificador del negocio asociado, si existe.
 * @property negocioNombre Nombre del negocio asociado, si existe.
 */
data class User(
    val id: String,
    val idGoogle: String,
    val nickname: String,
    val email: String,
    val rol: String,
    val tieneNegocio: Boolean,
    val negocioId: String? = null,
    val negocioNombre: String? = null
)
