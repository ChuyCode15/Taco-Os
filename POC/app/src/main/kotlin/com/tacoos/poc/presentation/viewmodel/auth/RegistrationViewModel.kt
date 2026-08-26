package com.tacoos.poc.presentation.viewmodel.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.data.local.UserPreferences
import com.tacoos.poc.data.remote.BusinessApiService
import com.tacoos.poc.data.remote.dto.BackendErrorDto
import com.tacoos.poc.data.remote.dto.DatosRegistroNegocio
import com.tacoos.poc.presentation.uiState.business.BusinessUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import javax.inject.Inject

/**
 * ViewModel encargado de la lógica para el registro de nuevos negocios.
 * Proporciona campos reactivos para el formulario y gestiona la comunicación con el API de negocios.
 *
 * @param businessApi Servicio API para operaciones relacionadas con el negocio.
 * @param userPreferences Preferencias de usuario para gestionar la sesión local.
 * @param json Utilidad de serialización JSON.
 */
@HiltViewModel
class RegistrationViewModel @Inject constructor(
    private val businessApi: BusinessApiService,
    private val userPreferences: UserPreferences,
    private val json: Json
) : ViewModel() {

    private val _uiState = MutableStateFlow(BusinessUiState())
    
    /**
     * Flujo de estado de la interfaz de usuario para el registro de negocio.
     */
    val uiState: StateFlow<BusinessUiState> = _uiState

    /**
     * Actualiza el nombre del negocio en el estado.
     */
    fun onNombreChange(value: String) {
        _uiState.update { it.copy(nombre = value) }
    }

    /**
     * Actualiza el domicilio del negocio en el estado.
     */
    fun onDomicilioChange(value: String) {
        _uiState.update { it.copy(domicilio = value) }
    }

    /**
     * Actualiza el teléfono del negocio en el estado.
     */
    fun onTelefonoChange(value: String) {
        _uiState.update { it.copy(telefono = value) }
    }

    /**
     * Actualiza el giro o categoría del negocio en el estado.
     */
    fun onGiroChange(value: String) {
        _uiState.update { it.copy(giro = value) }
    }

    /**
     * Actualiza el número de empleados en el estado.
     */
    fun onEmpleadosChange(value: String) {
        _uiState.update { it.copy(empleados = value) }
    }

    /**
     * Actualiza el horario de cierre en el estado.
     */
    fun onHorarioChange(value: String) {
        _uiState.update { it.copy(horarioCierre = value) }
    }

    /**
     * Ejecuta el registro del negocio en el servidor y actualiza la sesión local si es exitoso.
     */
    fun registerBusiness() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            try {
                val user = userPreferences.session.first()
                if (user == null) {
                    _uiState.update { it.copy(isLoading = false, errorMessage = "Sesión no encontrada") }
                    return@launch
                }

                val request = DatosRegistroNegocio(
                    nombre = _uiState.value.nombre,
                    direccion = _uiState.value.domicilio,
                    telefono = _uiState.value.telefono,
                    giro = _uiState.value.giro,
                    empleados = _uiState.value.empleados.toIntOrNull() ?: 1,
                    horarioCierre = _uiState.value.horarioCierre
                )

                val response = businessApi.registerBusiness(request, user.id)
                
                // Actualizar sesión local para indicar que ya tiene negocio
                val updatedUser = user.copy(
                    tieneNegocio = true,
                    negocioId = response.id,
                    negocioNombre = response.nombre
                )
                userPreferences.saveSession(updatedUser, userPreferences.getAccessToken() ?: "", null)

                _uiState.update { it.copy(
                    isLoading = false, 
                    isSuccess = true,
                    successMessage = "¡Negocio '${response.nombre}' registrado con éxito!"
                ) }
            } catch (e: HttpException) {
                val errorBody = e.response()?.errorBody()?.string()
                val message = try {
                    val errorDto = errorBody?.let { json.decodeFromString<BackendErrorDto>(it) }
                    errorDto?.mensaje ?: "Error en el servidor: ${e.code()}"
                } catch (parseException: Exception) {
                    "Error de servidor (${e.code()})"
                }
                _uiState.update { it.copy(isLoading = false, errorMessage = message) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, errorMessage = "Error de conexión") }
            }
        }
    }
}
