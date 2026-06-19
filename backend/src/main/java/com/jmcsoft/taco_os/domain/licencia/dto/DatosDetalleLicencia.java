package com.jmcsoft.taco_os.domain.licencia.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "License detail response")
public record DatosDetalleLicencia(
        @JsonProperty("plan")
        @Schema(description = "Current plan name", example = "Premium")
        String plan,
        @JsonProperty("status")
        @Schema(description = "License status", example = "active")
        String estado,
        @JsonProperty("start_date")
        @Schema(description = "License start date", example = "2025-01-01")
        String fechaInicio,
        @JsonProperty("end_date")
        @Schema(description = "License end date", example = "2025-12-31")
        String fechaFin,
        @JsonProperty("trial_end_date")
        @Schema(description = "Trial end date", example = "2025-01-15")
        String fechaFinTrial,
        @JsonProperty("days_remaining")
        @Schema(description = "Days remaining until license expires", example = "345")
        Integer diasRestantes,
        @JsonProperty("max_cashiers")
        @Schema(description = "Maximum number of cashiers allowed", example = "5")
        Integer maxCajeros,
        @JsonProperty("current_cashiers")
        @Schema(description = "Current number of active cashiers", example = "2")
        Integer cajerosActuales,
        @JsonProperty("max_businesses")
        @Schema(description = "Maximum number of businesses allowed", example = "3")
        Integer maxNegocios,
        @JsonProperty("current_businesses")
        @Schema(description = "Current number of active businesses", example = "1")
        Integer negociosActuales,
        @JsonProperty("features")
        @Schema(description = "List of features included in the license")
        List<String> features
) {}
