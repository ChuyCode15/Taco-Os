package com.jmcsoft.taco_os.domain.licencia.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "Available plans response")
public record DatosListaPlanes(
        @Schema(description = "Array of subscription plans")
        List<DatosPlan> planes
) {}
