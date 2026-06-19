package com.jmcsoft.taco_os.domain.licencia.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to upgrade plan")
public record DatosUpgradePlan(
        @JsonProperty("plan")
        @Schema(description = "Target plan name", example = "Premium")
        String plan,
        @JsonProperty("payment_method")
        @Schema(description = "Payment method identifier", example = "credit_card")
        String metodoPago
) {}
