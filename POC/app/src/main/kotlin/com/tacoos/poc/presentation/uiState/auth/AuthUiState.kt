package com.tacoos.poc.presentation.uiState.auth

/**
 * Estado de la interfaz de usuario para el flujo de autenticación.
 *
 * @property isLoading Indica si hay una operación de carga en curso.
 * @property errorMessage Mensaje de error a mostrar, si existe.
 * @property isAuthenticated Indica si el usuario ha iniciado sesión correctamente.
 * @property nickname Nombre o apodo del usuario autenticado.
 * @property rol Rol asignado al usuario (ej. "Dueño", "Cajero").
 * @property tieneNegocio Indica si el usuario ya tiene un negocio registrado.
 * @property fotoUrl URL de la foto de perfil del usuario.
 */
data class AuthUiState(
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val isAuthenticated: Boolean = false,
    val nickname: String = "",
    val rol: String = "",
    val tieneNegocio: Boolean = false,
    val fotoUrl: String? = null
)
