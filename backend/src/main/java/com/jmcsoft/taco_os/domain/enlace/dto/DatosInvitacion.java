package com.jmcsoft.taco_os.domain.enlace.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Invitation code response")
public record DatosInvitacion(

        @Schema(description = "Invitation code", example = "INV-ABC123")
        String codigo,

        @Schema(description = "Expiration time in minutes", example = "30")
        Integer expiraEn,

        @Schema(description = "QR code payload", example = "https://app.example.com/join/INV-ABC123")
        String qrPayload

) {
}
