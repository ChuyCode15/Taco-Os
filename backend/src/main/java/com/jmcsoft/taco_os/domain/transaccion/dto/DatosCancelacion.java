package com.jmcsoft.taco_os.domain.transaccion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to cancel a transaction")
public record DatosCancelacion(
        @JsonProperty("reason") @Schema(description = "Reason for cancellation", example = "Customer changed mind") String motivo,
        @JsonProperty("photo") @Schema(description = "Evidence photo URL", example = "https://example.com/photo.jpg") String fotoUrl,
        @JsonProperty("cashier_id") @Schema(description = "Cashier identifier", example = "cashier-789") String cajeroId
) {}
