package com.jmcsoft.taco_os.domain.superusuario.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Admin tenant detail for SuperUser dashboard")
public record DatosDetalleAdminTenant(
        @Schema(description = "Admin UUID")
        String id,

        @Schema(description = "Google ID", example = "110234567890123456789")
        String idGoogle,

        @Schema(description = "Full name", example = "Juan Pérez")
        String nombreCompleto,

        @Schema(description = "Nickname", example = "JuanTacos")
        String nickname,

        @Schema(description = "Email", example = "juan@tacos.com")
        String correo,

        @Schema(description = "Phone", example = "+521234567890")
        String numero,

        @Schema(description = "Business UUID")
        String negocioId,

        @Schema(description = "Business name", example = "Tacos El Güero")
        String negocioNombre,

        @Schema(description = "Plan type", example = "FREE")
        String tipoPlan,

        @Schema(description = "Plan status", example = "PAGADO")
        String estadoPlan,

        @Schema(description = "Plan due date", example = "2025-12-31")
        String fechaVencimiento,

        @Schema(description = "Active status", example = "true")
        Boolean activo,

        @Schema(description = "Creation date", example = "2025-01-15")
        String registro
) {}
