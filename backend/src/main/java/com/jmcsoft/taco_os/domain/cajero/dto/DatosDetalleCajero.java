package com.jmcsoft.taco_os.domain.cajero.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Cashier detail response")
public record DatosDetalleCajero(

        @Schema(description = "Cashier UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String id,

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

        @Schema(description = "Business UUID", example = "550e8400-e29b-41d4-a716-446655440000")
        String negocioId,

        @Schema(description = "Business name", example = "Tacos El Güero")
        String negocioNombre,

        @Schema(description = "Permission level", example = "ADMIN")
        String permisos,

        @Schema(description = "Creation date", example = "2025-06-18")
        String registro

) {
}
