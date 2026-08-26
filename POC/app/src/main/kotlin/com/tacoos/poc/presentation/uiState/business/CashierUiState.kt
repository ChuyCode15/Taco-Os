package com.tacoos.poc.presentation.uiState.business

/**
 * Estado de la interfaz de usuario para la visualización de la lista de cajeros.
 *
 * @property cashiers Lista de nombres de los cajeros registrados.
 * @property isLoading Indica si la lista de cajeros está siendo cargada desde el servidor.
 * @property errorMessage Mensaje de error en caso de que la carga falle.
 */
data class CashierUiState(
    val cashiers: List<String> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)
