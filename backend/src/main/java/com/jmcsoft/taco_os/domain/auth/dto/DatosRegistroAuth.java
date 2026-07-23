package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request body for user registration")
public record DatosRegistroAuth(

        @JsonProperty("idGoogle")
        @Schema(description = "Google account ID", example = "110234567890123456789")
        String idGoogle,

        @Schema(description = "Display name", example = "JuanTacos")
        String nickname,

        @Schema(description = "Email address", example = "juan@tacos.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero,

        @Schema(description = "User role: dueño or cajero", example = "dueño")
        String rol

) {
}
