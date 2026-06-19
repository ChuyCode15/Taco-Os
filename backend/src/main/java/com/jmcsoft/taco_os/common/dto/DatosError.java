package com.jmcsoft.taco_os.common.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Standard error response")
public record DatosError(

        @Schema(description = "Error code", example = "NO_ENCONTRADO")
        String codigo,
        @Schema(description = "Error message", example = "El recurso no fue encontrado")
        String mensaje,
        @Schema(description = "Error location", example = "NegocioHelper.validarIdNegocio")
        String ubicacion,
        @Schema(description = "HTTP status code", example = "404")
        Integer status

) {
}
