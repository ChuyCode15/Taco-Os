package com.jmcsoft.taco_os.domain.master.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Login response for Control Maestro")
public record DatosRespuestaMaster(
        @Schema(description = "JWT token")
        String token,
        @Schema(description = "Token expiration in hours")
        Integer vencimiento,
        @Schema(description = "User info")
        DatosUsuarioMaster usuario
) {}
