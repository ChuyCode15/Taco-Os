package com.jmcsoft.taco_os.domain.superusuario.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "SuperUser login response")
public record DatosRespuestaSuperSu(
        @Schema(description = "JWT token")
        String token,

        @Schema(description = "Token expiration in seconds", example = "3600")
        Integer vencimiento,

        @Schema(description = "SuperUser info")
        String username,

        @Schema(description = "Full name", example = "Super Administrador")
        String nombreCompleto
) {}
