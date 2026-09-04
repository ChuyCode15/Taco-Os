package com.tacoos.poc.presentation.uiState.ops

import com.tacoos.poc.domain.model.AppNotification

data class NotificationUiState(
    val isLoading: Boolean = false,
    val notifications: List<AppNotification> = emptyList(),
    val error: String? = null
)
