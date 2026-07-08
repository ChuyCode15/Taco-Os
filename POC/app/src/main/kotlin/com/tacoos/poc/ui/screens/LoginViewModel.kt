package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.remote.NetworkUtils
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class LoginUiState {
    object Idle : LoginUiState()
    object Loading : LoginUiState()
    data class Success(val user: User) : LoginUiState()
    object UserNotFound : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}

object GoogleSignInState {
    var idGoogle: String = ""
    var nombre: String = ""
    var email: String = ""
    var fotoUrl: String? = null
    var rol: String = "dueño" // Por defecto
    var userId: String = ""    // ID interno tras registerUser
    var token: String = ""     // JWT para peticiones autenticadas
}

class LoginViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = TacoRepository(app.api, app.database)

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState

    fun onGoogleSignInResult(idGoogle: String, nombre: String, email: String, fotoUrl: String?) {
        _uiState.value = LoginUiState.Loading

        GoogleSignInState.idGoogle = idGoogle
        GoogleSignInState.nombre = nombre
        GoogleSignInState.email = email
        GoogleSignInState.fotoUrl = fotoUrl

        viewModelScope.launch {
            try {
                val response = repository.verifyUser(idGoogle)
                if (response.existe && response.usuario != null) {
                    GoogleSignInState.token = response.token ?: ""
                    val user = User(
                        id = response.usuario.id,
                        idGoogle = idGoogle,
                        nombre = response.usuario.nickname ?: nombre,
                        email = response.usuario.correo ?: email,
                        rol = response.usuario.rol ?: "dueño",
                        negocioId = response.usuario.negocioId
                    )
                    repository.saveUserLocally(user)
                    _uiState.value = LoginUiState.Success(user)
                } else {
                    _uiState.value = LoginUiState.UserNotFound
                }
            } catch (e: retrofit2.HttpException) {
                if (e.code() == 404) {
                    _uiState.value = LoginUiState.UserNotFound
                } else {
                    android.util.Log.e("TacoOs", "Error HTTP en verifyUser: ${e.code()}", e)
                    _uiState.value = LoginUiState.Error(NetworkUtils.parseError(e))
                }
            } catch (e: Exception) {
                android.util.Log.e("TacoOs", "Error en verifyUser: ${e.message}", e)
                _uiState.value = LoginUiState.Error(NetworkUtils.parseError(e))
            }
        }
    }

    fun resetState() {
        _uiState.value = LoginUiState.Idle
    }
}

object GoogleSignInConfig {
    //const val SERVER_CLIENT_ID = "774869540338-4mjgliv50mtrt6cb8e9kpnju1ims1g2f.apps.googleusercontent.com"
    const val SERVER_CLIENT_ID = "921503491132-b9pipphh5no9mi4lljc5lr8dus8rf86h.apps.googleusercontent.com"
}
