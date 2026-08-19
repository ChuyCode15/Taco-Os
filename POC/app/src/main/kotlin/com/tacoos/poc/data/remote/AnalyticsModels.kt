package com.tacoos.poc.data.remote

data class AnalyticsReportResponse(
    val status: String,
    val reporte_ai: String? = null,
    val insights: Map<String, Any>? = null
)
