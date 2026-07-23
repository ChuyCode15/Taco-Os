package com.jmcsoft.taco_os.domain.master.invoice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "Billing summary")
public record DatosResumenFacturacion(
        @Schema(description = "Total monthly revenue")
        BigDecimal ingresosMensuales,
        @Schema(description = "Paid this month")
        BigDecimal pagadosMes,
        @Schema(description = "Pending this month")
        BigDecimal pendientesMes,
        @Schema(description = "MRR - Monthly Recurring Revenue")
        BigDecimal mrr,
        @Schema(description = "Clients by plan")
        java.util.Map<String, Integer> clientesPorPlan
) {}
