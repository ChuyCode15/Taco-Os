package com.jmcsoft.taco_os.domain.sesioncajero.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Cashier session detail response")
public record DatosDetalleSesion(
        @Schema(description = "Session UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String id,

        @Schema(description = "Session ID", example = "sesion-001")
        @JsonProperty("session_id") String sessionId,

        @Schema(description = "Session status", example = "OPEN")
        @JsonProperty("status") String estado,

        @Schema(description = "Session opening time", example = "2026-06-18T09:00:00")
        @JsonProperty("opened_at") String apertura,

        @Schema(description = "Opening balance", example = "500.00")
        @JsonProperty("opening_balance") BigDecimal fondoApertura
) {}
