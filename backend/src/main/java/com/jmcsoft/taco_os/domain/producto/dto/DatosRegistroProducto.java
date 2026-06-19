package com.jmcsoft.taco_os.domain.producto.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Request body to create/update a product")
public record DatosRegistroProducto(

        @Schema(description = "Product name", example = "Taco al pastor")
        @JsonProperty("name")
        String nombre,

        @Schema(description = "Product price", example = "15.00")
        @JsonProperty("price")
        BigDecimal precio,

        @Schema(description = "Product category", example = "Tacos")
        @JsonProperty("category")
        String categoria,

        @Schema(description = "Photo URL", example = "https://storage.tacoos.com/taco-pastor.jpg")
        @JsonProperty("photo_url")
        String fotoUrl

) {
}
