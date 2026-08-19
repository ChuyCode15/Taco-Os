package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.remote.AnalyticsReportResponse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class DashboardUiState {
    object Idle : DashboardUiState()
    object Loading : DashboardUiState()
    data class Success(val aiReport: String) : DashboardUiState()
    data class Error(val message: String) : DashboardUiState()
}

class DashboardViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = TacoRepository(app.api, app.database)

    private val _uiState = MutableStateFlow<DashboardUiState>(DashboardUiState.Idle)
    val uiState: StateFlow<DashboardUiState> = _uiState

    fun fetchAiInsight(negocioId: String?) {
        if (negocioId == null) {
            _uiState.value = DashboardUiState.Error("No se encontró el ID del negocio")
            return
        }

        _uiState.value = DashboardUiState.Loading
        viewModelScope.launch {
            try {
                // Llamamos al repositorio para obtener el insight de la IA
                val response: AnalyticsReportResponse = repository.getAiInsight(negocioId)
                
                // Verificamos si el reporte viene en 'reporte_ai' o en los 'insights'
                val reportText = response.reporte_ai ?: response.insights?.get("summary")?.toString()
                
                if (reportText != null) {
                    _uiState.value = DashboardUiState.Success(reportText)
                } else {
                    _uiState.value = DashboardUiState.Error("Aún no hay suficientes datos para generar un análisis")
                }
            } catch (e: Exception) {
                android.util.Log.e("DashboardViewModel", "Error fetching AI insight", e)
                _uiState.value = DashboardUiState.Error("Error de conexión con el servidor")
            }
        }
    }
}
