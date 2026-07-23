package com.jmcsoft.taco_os.domain.administrador.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request body to register an admin")
public record DatosRegistroAdmin(

        @Schema(description = "Google account identifier", example = "g-987654")
        String idGoogle,

        @Schema(description = "Full name", example = "Juan Perez")
        String nombreCompleto,

        @Schema(description = "Nickname", example = "jperez")
        String nickname,

        @Schema(description = "Email address", example = "juan@example.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero

) {
}
