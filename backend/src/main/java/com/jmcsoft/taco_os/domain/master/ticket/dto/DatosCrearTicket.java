package com.jmcsoft.taco_os.domain.master.ticket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Create ticket request")
public record DatosCrearTicket(
        @Schema(description = "Client ID (administrador)")
        String clienteId,
        @Schema(description = "Ticket title", example = "Error en corte diario")
        String titulo,
        @Schema(description = "Ticket description")
        String descripcion,
        @Schema(description = "Priority: URGENTE, ALTO, NORMAL, BAJO", example = "NORMAL")
        String prioridad
) {}
