package com.jmcsoft.taco_os.domain.producto.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

@Schema(description = "Request body to create/update a product")
public record DatosRegistroProducto(

        @Schema(description = "Product name", example = "Taco al pastor")
        @JsonProperty("name")
        @NotBlank(message = "El nombre del producto es obligatorio")
        String nombre,

        @Schema(description = "Product price", example = "15.00")
        @JsonProperty("price")
        @NotNull(message = "El precio es obligatorio")
        @DecimalMin(value = "0.01", message = "El precio debe ser mayor a 0")
        BigDecimal precio,

        @Schema(description = "Product category", example = "COMIDA")
        @JsonProperty("category")
        @NotBlank(message = "La categoría es obligatoria")
        String categoria,

        @Schema(description = "Photo URL", example = "https://storage.tacoos.com/taco-pastor.jpg")
        @JsonProperty("photo_url")
        String fotoUrl

) {
}
