package com.jmcsoft.taco_os.domain.negocio.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request body to create a business")
public record DatosRegistroNegocio(

        @Schema(description = "Business name", example = "Tacos El Güero")
        String nombre,

        @Schema(description = "Full address", example = "Av. Revolución 1234, Col. Centro")
        String direccion,

        @Schema(description = "Phone number", example = "+521234567890")
        String telefono,

        @JsonProperty("queVende")
        @Schema(description = "What they sell (category)", example = "Tacos al pastor")
        String giro,

        @Schema(description = "Number of employees", example = "4")
        Integer empleados,

        @JsonProperty("horario")
        @Schema(description = "Closing time", example = "22:00")
        String horarioCierre

) {
}
