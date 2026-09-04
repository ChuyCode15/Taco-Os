package com.tacoos.poc.presentation.viewmodel.ops

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.domain.usecase.ops.GetLicenseStatusUseCase
import com.tacoos.poc.presentation.uiState.ops.LicenseUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class LicenseViewModel @Inject constructor(
    private val getLicenseStatusUseCase: GetLicenseStatusUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LicenseUiState())
    val uiState = _uiState.asStateFlow()

    fun loadLicense(negocioId: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val result = getLicenseStatusUseCase(negocioId)
            result.onSuccess { license ->
                _uiState.update { it.copy(isLoading = false, license = license) }
            }.onFailure { error ->
                _uiState.update { it.copy(isLoading = false, error = error.message) }
            }
        }
    }
}
