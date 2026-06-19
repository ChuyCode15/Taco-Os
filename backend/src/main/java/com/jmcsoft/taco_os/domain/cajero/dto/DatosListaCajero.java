package com.jmcsoft.taco_os.domain.cajero.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Cashier summary in list")
public record DatosListaCajero(

        @Schema(description = "Cashier UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String id,

        @Schema(description = "Display nickname", example = "Juancho")
        String nickname,

        @Schema(description = "Email address", example = "juan@example.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero,

        @JsonProperty("tieneSesionAbierta")
        @Schema(description = "Whether the cashier has an active session", example = "true")
        Boolean tieneSesionAbierta,

        @JsonProperty("enlazadoEl")
        @Schema(description = "Date linked to business", example = "2025-06-18")
        String fechaEnlace

) {
}
