package com.jmcsoft.taco_os.domain.master.dashboard.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import java.util.Map;

@Schema(description = "Dashboard statistics")
public record DatosEstadisticas(
        @Schema(description = "Total active clients")
        Integer totalClientesActivos,
        @Schema(description = "Total inactive clients")
        Integer totalClientesInactivos,
        @Schema(description = "Active cashier sessions now")
        Integer sesionesAbiertas,
        @Schema(description = "Monthly revenue")
        java.math.BigDecimal ingresosMensuales,
        @Schema(description = "Open tickets")
        Integer ticketsAbiertos,
        @Schema(description = "Resolved tickets this month")
        Integer ticketsResueltos,
        @Schema(description = "Open incidents")
        Integer incidenciasAbiertas,
        @Schema(description = "Clients by plan")
        Map<String, Integer> clientesPorPlan,
        @Schema(description = "Revenue by month (last 6)")
        List<Map<String, Object>> ingresosPorMes,
        @Schema(description = "Recent activity")
        List<Map<String, Object>> actividadReciente
) {}
