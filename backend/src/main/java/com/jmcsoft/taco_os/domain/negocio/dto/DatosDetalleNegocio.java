package com.jmcsoft.taco_os.domain.negocio.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Business detail response")
public record DatosDetalleNegocio(

        @Schema(description = "Business UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String id,

        @Schema(description = "Business name", example = "Tacos El Güero")
        String nombre,

        @Schema(description = "Full address", example = "Av. Revolución 1234")
        String direccion,

        @Schema(description = "Phone number", example = "+521234567890")
        String telefono,

        @JsonProperty("queVende")
        @Schema(description = "What they sell", example = "Tacos al pastor")
        String giro,

        @Schema(description = "Number of employees", example = "4")
        Integer empleados,

        @JsonProperty("horario")
        @Schema(description = "Closing time", example = "22:00")
        String horarioCierre,

        @JsonProperty("creadoEl")
        @Schema(description = "Creation date", example = "2025-06-18")
        String registro

) {
}
