package com.jmcsoft.taco_os.domain.cajero.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "List of cashiers response")
public record DatosListaCajeros(

        @Schema(description = "Array of cashier summaries")
        List<DatosListaCajero> cajeros

) {
}
