package com.jmcsoft.taco_os.domain.master.message.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Message response")
public record DatosMensajeRespuesta(
        @Schema(description = "Message ID")
        String id,
        @Schema(description = "Sender name")
        String emisorNombre,
        @Schema(description = "Sender type: STAFF or CLIENT")
        String tipoEmisor,
        @Schema(description = "Message content")
        String contenido,
        @Schema(description = "Attachment URL")
        String urlAdjunto,
        @Schema(description = "Created at")
        String creadoEl
) {}
