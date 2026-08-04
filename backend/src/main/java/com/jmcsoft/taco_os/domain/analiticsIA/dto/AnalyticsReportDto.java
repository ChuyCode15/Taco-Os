package com.jmcsoft.taco_os.domain.analiticsIA.dto;

public record AnalyticsReportDto(
        String status,
        InsightsDto insights,
        String reporte_ai
) { }

