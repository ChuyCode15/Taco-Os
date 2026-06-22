package com.jmcsoft.taco_os.domain.master.operations.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "Adjust balance request")
public record DatosAjustarSaldo(
        @Schema(description = "Business ID")
        String negocioId,
        @Schema(description = "New base money amount")
        BigDecimal nuevoDineroBase,
        @Schema(description = "Reason for adjustment")
        String razon
) {}
