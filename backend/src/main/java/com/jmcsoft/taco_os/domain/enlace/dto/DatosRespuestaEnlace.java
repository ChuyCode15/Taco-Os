package com.jmcsoft.taco_os.domain.enlace.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Response after linking cashier to business")
public record DatosRespuestaEnlace(

        @Schema(description = "Whether linking was successful", example = "true")
        Boolean enlazado,

        @Schema(description = "Business identifier", example = "biz456")
        String negocioId,

        @Schema(description = "Business name", example = "Taco Shop")
        String negocioNombre,

        @Schema(description = "Business address", example = "123 Main St, Mexico City")
        String negocioDireccion,

        @Schema(description = "Currency", example = "MXN")
        String moneda,

        @JsonProperty("dineroBase")
        @Schema(description = "Base amount", example = "1000.00")
        BigDecimal dineroBase

) {
}
