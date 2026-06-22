package com.jmcsoft.taco_os.domain.master.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Master user info")
public record DatosUsuarioMaster(
        @Schema(description = "User ID")
        String id,
        @Schema(description = "Username")
        String username,
        @Schema(description = "Full name")
        String nombreCompleto,
        @Schema(description = "Email")
        String correo,
        @Schema(description = "Role: DEVELOPER, SOPORTE, DATA_SCIENTIST")
        String rol
) {}
