package com.jmcsoft.taco_os.domain.administrador.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Admin detail response")
public record DatosDetalleAdmin(

        @Schema(description = "Unique identifier", example = "abc123")
        String id,

        @Schema(description = "Google account identifier", example = "g-987654")
        String idGoogle,

        @Schema(description = "Full name", example = "Juan Perez")
        String nombreCompleto,

        @Schema(description = "Nickname", example = "jperez")
        String nickname,

        @Schema(description = "Email address", example = "juan@example.com")
        String correo,

        @Schema(description = "Phone number", example = "+521234567890")
        String numero,

        @Schema(description = "Business identifier", example = "biz456")
        String negocioId,

        @Schema(description = "Business name", example = "Taco Shop")
        String negocioNombre,

        @Schema(description = "Plan type", example = "Premium")
        String tipoPlan,

        @Schema(description = "Plan status", example = "Active")
        String estadoPlan,

        @Schema(description = "Expiration date", example = "2026-12-31")
        String fechaVencimiento,

        @Schema(description = "Registration date", example = "2025-01-15")
        String registro

) {
}
