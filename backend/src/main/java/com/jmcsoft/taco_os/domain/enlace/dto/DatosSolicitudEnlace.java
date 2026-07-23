package com.jmcsoft.taco_os.domain.enlace.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to link using an invitation code")
public record DatosSolicitudEnlace(

        @Schema(description = "Invitation code", example = "INV-ABC123")
        String codigo,

        @Schema(description = "User identifier", example = "usr789")
        String usuarioId

) {
}
