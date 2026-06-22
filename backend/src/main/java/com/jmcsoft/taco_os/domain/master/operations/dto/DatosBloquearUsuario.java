package com.jmcsoft.taco_os.domain.master.operations.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Block user request")
public record DatosBloquearUsuario(
        @Schema(description = "Admin ID to block/unblock")
        String clienteId,
        @Schema(description = "true to block, false to unblock")
        Boolean bloquear,
        @Schema(description = "Reason")
        String razon
) {}
