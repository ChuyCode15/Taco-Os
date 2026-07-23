package com.jmcsoft.taco_os.domain.corte.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Request to close a cashier session (daily cut)")
public record DatosCierreSesion(
        @JsonProperty("session_id") @Schema(description = "Cashier session identifier", example = "session-456") String sesionId,
        @JsonProperty("cashier_id") @Schema(description = "Cashier identifier", example = "cashier-789") String cajeroId,
        @JsonProperty("device_id") @Schema(description = "Device identifier", example = "device-001") String dispositivoId,
        @JsonProperty("actual_cash") @Schema(description = "Actual cash in drawer", example = "1250.00") BigDecimal efectivoReal,
        @JsonProperty("notes") @Schema(description = "Closing notes", example = "End of day shift") String notas
) {}
