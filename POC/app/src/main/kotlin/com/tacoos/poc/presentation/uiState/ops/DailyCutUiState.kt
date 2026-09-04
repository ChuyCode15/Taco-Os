package com.tacoos.poc.presentation.uiState.ops

import com.tacoos.poc.domain.model.DailyCut

data class DailyCutUiState(
    val isLoading: Boolean = false,
    val isClosing: Boolean = false,
    val currentCut: DailyCut? = null,
    val error: String? = null,
    val isSuccess: Boolean = false
)
