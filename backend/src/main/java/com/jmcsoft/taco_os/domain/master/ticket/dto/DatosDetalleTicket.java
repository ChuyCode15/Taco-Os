package com.jmcsoft.taco_os.domain.master.ticket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Ticket detail response")
public record DatosDetalleTicket(
        @Schema(description = "Ticket ID")
        String id,
        @Schema(description = "Client ID")
        String clienteId,
        @Schema(description = "Client name")
        String clienteNombre,
        @Schema(description = "Ticket title")
        String titulo,
        @Schema(description = "Ticket description")
        String descripcion,
        @Schema(description = "Priority")
        String prioridad,
        @Schema(description = "Status")
        String estado,
        @Schema(description = "Assigned to name")
        String asignadoA,
        @Schema(description = "Created at")
        String creadoEl,
        @Schema(description = "Resolved at")
        String resueltoEl
) {}
