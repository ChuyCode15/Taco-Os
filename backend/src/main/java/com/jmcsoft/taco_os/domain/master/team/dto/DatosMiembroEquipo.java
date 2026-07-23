package com.jmcsoft.taco_os.domain.master.team.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Team member list item")
public record DatosMiembroEquipo(
        @Schema(description = "User ID")
        String id,
        @Schema(description = "Username")
        String username,
        @Schema(description = "Full name")
        String nombreCompleto,
        @Schema(description = "Email")
        String correo,
        @Schema(description = "Role: DEVELOPER, SOPORTE, DATA_SCIENTIST")
        String rol,
        @Schema(description = "Active")
        Boolean activo,
        @Schema(description = "Open tickets assigned")
        Integer ticketsAsignados,
        @Schema(description = "Created at")
        String registro
) {}
