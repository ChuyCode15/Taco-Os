package com.tacoos.poc.presentation.viewmodel.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.core.util.AppResult
import com.tacoos.poc.domain.usecase.auth.GetSessionUseCase
import com.tacoos.poc.domain.usecase.auth.SignInWithGoogleUseCase
import com.tacoos.poc.presentation.uiState.auth.AuthUiState
import com.tacoos.poc.presentation.uiState.auth.GoogleUserData
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel que gestiona la lógica de autenticación y el estado de la sesión del usuario.
 *
 * @param signInWithGoogleUseCase Caso de uso para iniciar sesión con Google.
 * @param getSessionUseCase Caso de uso para obtener y observar la sesión del usuario.
 */
@HiltViewModel
class AuthViewModel @Inject constructor(
    private val signInWithGoogleUseCase: SignInWithGoogleUseCase,
    private val getSessionUseCase: GetSessionUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    
    /**
     * Flujo de estado de la interfaz de usuario para la autenticación.
     */
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        // Observar la sesión activa para mantener los datos actualizados
        getSessionUseCase().onEach { user ->
            _uiState.update { it.copy(
                isAuthenticated = user != null,
                nickname = user?.nickname ?: "",
                rol = user?.rol ?: "",
                tieneNegocio = user?.tieneNegocio ?: false
            ) }
        }.launchIn(viewModelScope)
    }

    /**
     * Inicia el proceso de inicio de sesión con los datos obtenidos de Google.
     *
     * @param userData Datos del usuario de Google.
     */
    fun onGoogleSignIn(userData: GoogleUserData) {
        execute {
            signInWithGoogleUseCase(
                idToken = userData.idToken,
                idGoogle = userData.idGoogle,
                email = userData.email,
                nickname = userData.nickname
            )
        }
    }

    /**
     * Maneja fallos en el flujo de Google Auth (ej. cancelación del usuario).
     *
     * @param message Mensaje de error a mostrar.
     */
    fun onGoogleFlowFailed(message: String) {
        _uiState.update { it.copy(isLoading = false, errorMessage = message) }
    }

    /**
     * Limpia el mensaje de error actual del estado.
     */
    fun consumeError() {
        _uiState.update { it.copy(errorMessage = null) }
    }

    /**
     * Función auxiliar para ejecutar operaciones asíncronas de autenticación y actualizar el estado.
     *
     * @param block Bloque de código a ejecutar que devuelve un [AppResult].
     */
    private fun execute(block: suspend () -> AppResult<*>) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            when (val result = block()) {
                is AppResult.Success -> _uiState.update {
                    it.copy(isLoading = false, isAuthenticated = true)
                }
                is AppResult.Error -> _uiState.update {
                    it.copy(isLoading = false, errorMessage = result.message)
                }
                else -> Unit
            }
        }
    }
}
