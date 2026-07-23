package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Response after successful registration")
public record DatosRespuestaAuth(

        @Schema(description = "Authentication token", example = "eyJhbGciOi...")
        String token,

        @Schema(description = "Token expiration in seconds", example = "3600")
        Integer vencimiento,

        @Schema(description = "Registered user data")
        DatosUsuarioAuth usuario

) {
}
