package com.jmcsoft.taco_os.domain.master.message.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Send message request")
public record DatosEnviarMensaje(
        @Schema(description = "Message content")
        String contenido,
        @Schema(description = "Attachment URL (optional)")
        String urlAdjunto
) {}
