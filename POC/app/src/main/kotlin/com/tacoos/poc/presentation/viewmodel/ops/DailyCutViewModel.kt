package com.tacoos.poc.presentation.viewmodel.ops

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.domain.usecase.ops.PerformDailyCutUseCase
import com.tacoos.poc.presentation.uiState.ops.DailyCutUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DailyCutViewModel @Inject constructor(
    private val performDailyCutUseCase: PerformDailyCutUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(DailyCutUiState())
    val uiState = _uiState.asStateFlow()

    fun performCorte(shiftId: Long, actualCash: Double) {
        viewModelScope.launch {
            _uiState.update { it.copy(isClosing = true, error = null) }
            val result = performDailyCutUseCase(shiftId, actualCash)
            result.onSuccess { cut ->
                _uiState.update { it.copy(isClosing = false, isSuccess = true, currentCut = cut) }
            }.onFailure { error ->
                _uiState.update { it.copy(isClosing = false, error = error.message) }
            }
        }
    }
}
