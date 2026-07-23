package com.jmcsoft.taco_os.domain.superusuario.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "Dashboard statistics for SuperUser")
public record DatosDashboardSuperSu(
        @Schema(description = "Total administrators", example = "25")
        Integer totalAdmins,

        @Schema(description = "Active administrators", example = "20")
        Integer adminsActivos,

        @Schema(description = "Total businesses", example = "30")
        Integer totalNegocios,

        @Schema(description = "Active businesses", example = "28")
        Integer negociosActivos,

        @Schema(description = "Total cashiers", example = "120")
        Integer totalCajeros,

        @Schema(description = "Businesses by plan")
        List<ConteoPlan> porPlan,

        @Schema(description = "Revenue this month", example = "15000.00")
        BigDecimal ingresosMes
) {}

@Schema(description = "Plan distribution count")
record ConteoPlan(
        @Schema(description = "Plan name", example = "FREE")
        String plan,

        @Schema(description = "Count", example = "15")
        Integer cantidad
) {}
