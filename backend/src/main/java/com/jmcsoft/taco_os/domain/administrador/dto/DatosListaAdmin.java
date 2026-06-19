package com.jmcsoft.taco_os.domain.administrador.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Admin summary in list")
public record DatosListaAdmin(

        @Schema(description = "Unique identifier", example = "abc123")
        String id,

        @Schema(description = "Full name", example = "Juan Perez")
        String nombreCompleto,

        @Schema(description = "Nickname", example = "jperez")
        String nickname,

        @Schema(description = "Email address", example = "juan@example.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero,

        @Schema(description = "Plan type", example = "Premium")
        String tipoPlan,

        @Schema(description = "Plan status", example = "Active")
        String estadoPlan

) {
}
