package com.jmcsoft.taco_os.domain.transaccion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Cancellation response")
public record DatosRespuestaCancelacion(
        @JsonProperty("status") @Schema(description = "Cancellation status", example = "cancelled") String estado,
        @JsonProperty("original_total") @Schema(description = "Original transaction total", example = "150.00") java.math.BigDecimal totalOriginal,
        @JsonProperty("cancelled_at") @Schema(description = "Cancellation timestamp", example = "2026-06-18T15:00:00Z") String canceladoEn,
        @JsonProperty("owner_notified") @Schema(description = "Whether the owner was notified", example = "true") Boolean notificado
) {}
