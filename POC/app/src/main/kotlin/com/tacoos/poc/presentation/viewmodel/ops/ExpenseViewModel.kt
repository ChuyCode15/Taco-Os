package com.tacoos.poc.presentation.viewmodel.ops

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tacoos.poc.domain.usecase.ops.GetExpensesUseCase
import com.tacoos.poc.presentation.uiState.ops.ExpenseUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ExpenseViewModel @Inject constructor(
    private val getExpensesUseCase: GetExpensesUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(ExpenseUiState())
    val uiState = _uiState.asStateFlow()

    fun loadExpenses(shiftId: Long) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val list = getExpensesUseCase(shiftId)
            _uiState.update { it.copy(isLoading = false, expenses = list) }
        }
    }
}
