package com.jmcsoft.taco_os.domain.cajero.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request body to register a cashier")
public record DatosRegistroCajero(

        @Schema(description = "Google account ID", example = "110209545832940389731")
        String idGoogle,

        @Schema(description = "Full name", example = "Juan Pérez López")
        String nombreCompleto,

        @Schema(description = "Display nickname", example = "Juancho")
        String nickname,

        @Schema(description = "Email address", example = "juan@example.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero,

        @Schema(description = "Invitation code", example = "ABC123")
        String codigoInvitacion

) {
}
