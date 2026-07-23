package com.jmcsoft.taco_os.domain.sesioncajero.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Request to open a cashier session")
public record DatosAperturaSesion(
        @Schema(description = "Business ID", example = "bizz-001")
        String businessId,

        @Schema(description = "Cashier ID", example = "cajero-001")
        String cashierId,

        @Schema(description = "Device ID", example = "device-001")
        String deviceId,

        @Schema(description = "Opening balance", example = "500.00")
        @JsonProperty("opening_balance") BigDecimal fondoApertura
) {}
