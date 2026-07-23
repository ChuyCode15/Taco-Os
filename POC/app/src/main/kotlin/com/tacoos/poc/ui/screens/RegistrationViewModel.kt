package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.local.User
import com.tacoos.poc.data.remote.NetworkUtils
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class RegistrationUiState {
    object Idle : RegistrationUiState()
    object Loading : RegistrationUiState()
    object UserCreated : RegistrationUiState()
    object BusinessCreated : RegistrationUiState()
    data class Success(val user: User) : RegistrationUiState()
    data class Error(val message: String) : RegistrationUiState()
}

class RegistrationViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = TacoRepository(app.api, app.database)

    private val _uiState = MutableStateFlow<RegistrationUiState>(RegistrationUiState.Idle)
    val uiState: StateFlow<RegistrationUiState> = _uiState

    fun selectRole(rol: String) {
        GoogleSignInState.rol = rol
    }

    fun registerUserAndBusiness(businessName: String, address: String, giro: String) {
        _uiState.value = RegistrationUiState.Loading
        viewModelScope.launch {
            try {
                // 1. Registrar Usuario en Backend
                val authResponse = repository.registerUser(
                    idGoogle = GoogleSignInState.idGoogle,
                    nombre = GoogleSignInState.nombre,
                    email = GoogleSignInState.email,
                    rol = GoogleSignInState.rol
                )

                val userId = authResponse.usuario?.id ?: throw Exception("Error al obtener ID de usuario")
                GoogleSignInState.userId = userId
                GoogleSignInState.token = authResponse.token ?: ""

                // 2. Crear Negocio (solo si es dueño)
                if (GoogleSignInState.rol == "dueño") {
                    val businessResponse = repository.createBusiness(
                        duenoId = userId,
                        nombre = businessName,
                        direccion = address,
                        giro = giro
                    )

                    // 3. Guardar localmente y finalizar
                    val user = User(
                        id = userId,
                        idGoogle = GoogleSignInState.idGoogle,
                        nombre = GoogleSignInState.nombre,
                        email = GoogleSignInState.email,
                        rol = GoogleSignInState.rol,
                        negocioId = businessResponse.id.toString()
                    )
                    repository.saveUserLocally(user)
                    _uiState.value = RegistrationUiState.Success(user)
                } else {
                    // Para cajeros, el flujo es diferente (esperar asignación)
                    _uiState.value = RegistrationUiState.UserCreated
                }

            } catch (e: Exception) {
                android.util.Log.e("TacoOs", "Error en registro: ${e.message}", e)
                _uiState.value = RegistrationUiState.Error(NetworkUtils.parseError(e))
            }
        }
    }

    fun registerCashier() {
        _uiState.value = RegistrationUiState.Loading
        viewModelScope.launch {
            try {
                val authResponse = repository.registerUser(
                    idGoogle = GoogleSignInState.idGoogle,
                    nombre = GoogleSignInState.nombre,
                    email = GoogleSignInState.email,
                    rol = "cajero"
                )
                val userId = authResponse.usuario?.id ?: ""
                GoogleSignInState.token = authResponse.token ?: ""
                
                val user = User(
                    id = userId,
                    idGoogle = GoogleSignInState.idGoogle,
                    nombre = GoogleSignInState.nombre,
                    email = GoogleSignInState.email,
                    rol = "cajero",
                    negocioId = null
                )
                repository.saveUserLocally(user)
                _uiState.value = RegistrationUiState.UserCreated
            } catch (e: Exception) {
                _uiState.value = RegistrationUiState.Error(NetworkUtils.parseError(e))
            }
        }
    }
}
