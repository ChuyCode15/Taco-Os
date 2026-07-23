package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "User authentication data")
public record DatosUsuarioAuth(

        @Schema(description = "Internal UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String id,

        @JsonProperty("idGoogle")
        @Schema(description = "Google account ID", example = "110234567890123456789")
        String idGoogle,

        @Schema(description = "Display name", example = "JuanTacos")
        String nickname,

        @Schema(description = "Email address", example = "juan@tacos.com")
        String correo,

        @Schema(description = "User role", example = "dueño")
        String rol,

        @JsonProperty("tieneNegocio")
        @Schema(description = "Whether user has a linked business", example = "true")
        Boolean tieneNegocio,

        @Schema(description = "Business UUID (null if no business)", example = "550e8400-e29b-41d4-a716-446655440000")
        String negocioId,

        @Schema(description = "Business name (null if no business)", example = "Tacos El Güero")
        String negocioNombre

) {
}
