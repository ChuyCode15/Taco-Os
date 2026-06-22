package com.jmcsoft.taco_os.domain.master.operations.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Force close session request")
public record DatosForzarCierre(
        @Schema(description = "Cashier ID")
        String cajeroId,
        @Schema(description = "Reason")
        String razon
) {}
