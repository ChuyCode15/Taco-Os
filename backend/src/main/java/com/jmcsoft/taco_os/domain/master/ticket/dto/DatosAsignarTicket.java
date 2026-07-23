package com.jmcsoft.taco_os.domain.master.ticket.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Assign ticket request")
public record DatosAsignarTicket(
        @Schema(description = "Staff user ID to assign")
        String asignadoA
) {}
