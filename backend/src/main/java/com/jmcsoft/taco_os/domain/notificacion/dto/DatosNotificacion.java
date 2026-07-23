package com.jmcsoft.taco_os.domain.notificacion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Notification detail")
public record DatosNotificacion(
        @Schema(description = "Notification identifier", example = "notif-abc123")
        String id,
        @JsonProperty("type")
        @Schema(description = "Notification type", example = "info")
        String tipo,
        @Schema(description = "Notification message", example = "Your plan has been updated")
        String message,
        @Schema(description = "Additional notification data", example = "null")
        String data,
        @JsonProperty("is_read")
        @Schema(description = "Whether the notification has been read", example = "false")
        Boolean leido,
        @JsonProperty("created_at")
        @Schema(description = "Notification creation timestamp", example = "2025-01-15T10:30:00Z")
        String registro
) {}
