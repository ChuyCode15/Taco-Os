package com.jmcsoft.taco_os.domain.transaccion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Transaction response")
public record DatosRespuestaTransaccion(
        @Schema(description = "Transaction identifier", example = "txn-abc-123") String id,
        @JsonProperty("status") @Schema(description = "Transaction status", example = "completed") String estado,
        @JsonProperty("timestamp") @Schema(description = "Transaction timestamp", example = "2026-06-18T14:30:00Z") String marcaTiempo
) {}
