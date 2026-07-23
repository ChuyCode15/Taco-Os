package com.jmcsoft.taco_os.domain.master.client.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Client list item")
public record DatosClienteLista(
        @Schema(description = "Admin ID")
        String id,
        @Schema(description = "Full name")
        String nombreCompleto,
        @Schema(description = "Nickname")
        String nickname,
        @Schema(description = "Email")
        String correo,
        @Schema(description = "Phone")
        String numero,
        @Schema(description = "Business name")
        String negocioNombre,
        @Schema(description = "Plan: FREE, BUSINESS, PREMIUM")
        String plan,
        @Schema(description = "Active")
        Boolean activo,
        @Schema(description = "Created at")
        String registro
) {}
