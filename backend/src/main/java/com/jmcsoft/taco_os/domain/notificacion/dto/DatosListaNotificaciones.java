package com.jmcsoft.taco_os.domain.notificacion.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "List of notifications response")
public record DatosListaNotificaciones(
        @Schema(description = "Array of notifications")
        List<DatosNotificacion> notificaciones
) {}
