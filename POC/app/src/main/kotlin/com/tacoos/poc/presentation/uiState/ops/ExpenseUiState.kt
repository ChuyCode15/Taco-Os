package com.tacoos.poc.presentation.uiState.ops

import com.tacoos.poc.domain.model.Expense

data class ExpenseUiState(
    val isLoading: Boolean = false,
    val expenses: List<Expense> = emptyList(),
    val error: String? = null
)
