package com.jmcsoft.taco_os.domain.master.team.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Create team member request")
public record DatosCrearMiembro(
        @Schema(description = "Username", example = "nuevoSoporte")
        String username,
        @Schema(description = "Password", example = "pass123")
        String password,
        @Schema(description = "Full name", example = "María Soporte")
        String nombreCompleto,
        @Schema(description = "Email", example = "maria@tacoos.com")
        String correo,
        @Schema(description = "Role: DEVELOPER, SOPORTE, DATA_SCIENTIST")
        String rol
) {}
