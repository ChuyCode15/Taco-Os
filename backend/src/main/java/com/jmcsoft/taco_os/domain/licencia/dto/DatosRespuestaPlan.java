package com.jmcsoft.taco_os.domain.licencia.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Plan upgrade/change response")
public record DatosRespuestaPlan(
        @JsonProperty("status")
        @Schema(description = "Response status", example = "success")
        String estado,
        @JsonProperty("plan")
        @Schema(description = "Current plan name", example = "Premium")
        String plan,
        @JsonProperty("end_date")
        @Schema(description = "Plan end date", example = "2025-12-31")
        String fechaFin,
        @JsonProperty("message")
        @Schema(description = "Response message", example = "Plan upgraded successfully")
        String mensaje
) {}
