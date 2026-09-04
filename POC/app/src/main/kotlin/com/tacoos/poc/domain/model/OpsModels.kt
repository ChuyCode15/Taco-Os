package com.tacoos.poc.domain.model

/**
 * Representa un corte de caja procesado.
 */
data class DailyCut(
    val id: String,
    val totalSales: Double,
    val totalExpenses: Double,
    val cashSales: Double,
    val cardSales: Double,
    val expectedCash: Double,
    val actualCash: Double,
    val difference: Double,
    val closedAt: String,
    val notes: String? = null
)

/**
 * Representa un gasto operativo.
 */
data class Expense(
    val id: String,
    val detail: String,
    val amount: Double,
    val category: String,
    val timestamp: Long,
    val cashierName: String
)

/**
 * Estado de la licencia del negocio.
 */
data class LicenseStatus(
    val negocioId: String,
    val status: String, // ACTIVE, EXPIRED, TRIAL
    val expiryDate: String,
    val planName: String
)

/**
 * Notificación del sistema para el usuario.
 */
data class AppNotification(
    val id: String,
    val title: String,
    val message: String,
    val timestamp: Long,
    val isRead: Boolean
)
