package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Response for user verification endpoint")
public record DatosVerificacionAuth(
        @Schema(description = "Whether the user exists", example = "true")
        Boolean existe,

        @Schema(description = "Authentication token", example = "eyJhbGciOi...")
        String token,

        @Schema(description = "Token expiration in seconds", example = "3600")
        Integer vencimiento,

        @Schema(description = "User data (only when exists=true)")
        DatosUsuarioAuth usuario
) {}
