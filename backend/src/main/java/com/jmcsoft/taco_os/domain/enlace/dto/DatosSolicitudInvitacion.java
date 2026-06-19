package com.jmcsoft.taco_os.domain.enlace.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to generate an invitation code")
public record DatosSolicitudInvitacion(

        @Schema(description = "Business identifier", example = "biz456")
        String negocioId,

        @Schema(description = "Owner identifier", example = "usr789")
        String duenoId

) {
}
