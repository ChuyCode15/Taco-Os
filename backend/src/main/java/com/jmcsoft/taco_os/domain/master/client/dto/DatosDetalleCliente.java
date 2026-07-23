package com.jmcsoft.taco_os.domain.master.client.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Client detail response")
public record DatosDetalleCliente(
        @Schema(description = "Admin ID")
        String id,
        @Schema(description = "Google ID")
        String idGoogle,
        @Schema(description = "Full name")
        String nombreCompleto,
        @Schema(description = "Nickname")
        String nickname,
        @Schema(description = "Email")
        String correo,
        @Schema(description = "Phone")
        String numero,
        @Schema(description = "Business ID")
        String negocioId,
        @Schema(description = "Business name")
        String negocioNombre,
        @Schema(description = "Business address")
        String negocioDireccion,
        @Schema(description = "Plan type")
        String plan,
        @Schema(description = "Plan status")
        String estadoPlan,
        @Schema(description = "Plan due date")
        String fechaVencimiento,
        @Schema(description = "Active")
        Boolean activo,
        @Schema(description = "Linked cashiers count")
        Integer totalCajeros,
        @Schema(description = "Open tickets count")
        Integer ticketsAbiertos,
        @Schema(description = "Created at")
        String registro
) {}
