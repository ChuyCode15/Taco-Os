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

/**
 * LoginUiState: Estados posibles para la interfaz de usuario durante la autenticación.
 */
sealed class LoginUiState {
    object Idle : LoginUiState()
    object Loading : LoginUiState()
    data class Success(val user: User) : LoginUiState()
    object UserNotFound : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}

/**
 * GoogleSignInState: Singleton que almacena la información de la identidad obtenida desde Google.
 * Facilita el acceso a los datos del usuario en toda la aplicación durante el ciclo de vida del proceso.
 */
object GoogleSignInState {
    var idGoogle: String = ""
    var nombre: String = ""
    var email: String = ""
    var fotoUrl: String? = null
    var rol: String = "dueño" // Rol predeterminado para el flujo de registro.
    var userId: String = ""    // ID generado internamente por el sistema tras el registro.
    var token: String = ""     // JWT proporcionado por el Backend para peticiones autenticadas.
    var negocioId: String? = null // ID del negocio vinculado al usuario.
}

/**
 * LoginViewModel: Gestiona el estado y la lógica de negocio para el inicio de sesión.
 * Inyección de dependencias: Recibe la instancia de la aplicación para acceder al repositorio central.
 */
class LoginViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    // El repositorio abstrae el acceso a datos locales (SQLite) y remotos (Retrofit).
    private val repository = TacoRepository(app.api, app.database)

    // Estado reactivo observado por la vista (LoginScreen).
    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState

    /**
     * onGoogleSignInResult: Procesa el resultado de la autenticación externa y lo valida con el servidor.
     */
    fun onGoogleSignInResult(idGoogle: String, nombre: String, email: String, fotoUrl: String?) {
        _uiState.value = LoginUiState.Loading

        // Persistencia temporal de la identidad de Google.
        GoogleSignInState.idGoogle = idGoogle
        GoogleSignInState.nombre = nombre
        GoogleSignInState.email = email
        GoogleSignInState.fotoUrl = fotoUrl

        viewModelScope.launch {
            try {
                // Comunicación con el Backend: Verifica si el usuario ya está registrado en el ecosistema Taco'Os.
                val response = repository.verifyUser(idGoogle)
                if (response.existe && response.usuario != null) {
                    GoogleSignInState.token = response.token ?: ""
                    GoogleSignInState.negocioId = response.usuario.negocioId
                    val user = User(
                        id = response.usuario.id,
                        idGoogle = idGoogle,
                        nombre = response.usuario.nickname ?: nombre,
                        email = response.usuario.correo ?: email,
                        rol = response.usuario.rol ?: "dueño",
                        negocioId = response.usuario.negocioId
                    )
                    // Inyección de persistencia local: Guarda el perfil en SQLite (Room).
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

    /**
     * resetState: Reinicia el flujo de autenticación al estado base.
     */
    fun resetState() {
        _uiState.value = LoginUiState.Idle
    }
}

/**
 * GoogleSignInConfig: Constantes de configuración para el SDK de Google Auth.
 */
object GoogleSignInConfig {

        // Client ID vinculado al proyecto en Google Cloud Console.
    //const val SERVER_CLIENT_ID = "774869540338-4mjgliv50mtrt6cb8e9kpnju1ims1g2f.apps.googleusercontent.com"
    const val SERVER_CLIENT_ID = "921503491132-b9pipphh5no9mi4lljc5lr8dus8rf86h.apps.googleusercontent.com"
}
