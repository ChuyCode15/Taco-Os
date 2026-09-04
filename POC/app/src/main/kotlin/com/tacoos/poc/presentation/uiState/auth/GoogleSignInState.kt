package com.tacoos.poc.presentation.uiState.auth

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * GoogleSignInState: Estado global para compatibilidad con pantallas legacy.
 * NOTA: En la versión final, esto debería migrarse a AuthViewModel + DataStore.
 */
object GoogleSignInState {
    var userId by mutableStateOf("")
    var nombre by mutableStateOf("")
    var email by mutableStateOf("")
    var token by mutableStateOf("")
    var rol by mutableStateOf("dueño")
    var negocioId: String? by mutableStateOf(null)
    var tieneNegocio by mutableStateOf(false)
}
