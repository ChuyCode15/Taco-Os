package com.tacoos.poc.presentation.uiState.ops

import com.tacoos.poc.domain.model.LicenseStatus

data class LicenseUiState(
    val isLoading: Boolean = false,
    val license: LicenseStatus? = null,
    val error: String? = null
)
