package com.tacoos.poc.presentation.viewmodel.business

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.data.local.UserPreferences
import com.tacoos.poc.data.remote.BusinessApiService
import com.tacoos.poc.presentation.uiState.business.CashierUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel que gestiona la lista de cajeros asociados a un negocio.
 * Se encarga de obtener la información del negocio del usuario y solicitar la lista de cajeros al servidor.
 *
 * @param businessApi Servicio API para obtener datos del negocio y sus empleados.
 * @param userPreferences Preferencias del usuario para obtener el ID del negocio actual.
 */
@HiltViewModel
class CashierListViewModel @Inject constructor(
    private val businessApi: BusinessApiService,
    private val userPreferences: UserPreferences
) : ViewModel() {

    private val _uiState = MutableStateFlow(CashierUiState())
    
    /**
     * Flujo de estado de la interfaz de usuario para la lista de cajeros.
     */
    val uiState: StateFlow<CashierUiState> = _uiState.asStateFlow()

    init {
        loadCashiers()
    }

    /**
     * Carga la lista de cajeros desde el servidor.
     * Identifica el negocio del usuario actual antes de realizar la petición.
     */
    fun loadCashiers() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            try {
                val user = userPreferences.session.first()
                val businessId = user?.negocioId
                
                if (businessId != null) {
                    val response = businessApi.getCajeros(businessId)
                    _uiState.update { it.copy(
                        isLoading = false,
                        cashiers = response.cajeros
                    ) }
                } else {
                    _uiState.update { it.copy(
                        isLoading = false,
                        errorMessage = "No se encontró un negocio vinculado a tu cuenta."
                    ) }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar cajeros: ${e.message}"
                ) }
            }
        }
    }
}
