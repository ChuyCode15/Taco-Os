package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Response for user verification (login check)")
@JsonInclude(JsonInclude.Include.NON_NULL)
public record DatosVerificarAuth(

        @JsonProperty("existe")
        @Schema(description = "Whether the user exists", example = "true")
        Boolean existe,

        @Schema(description = "Authentication token", example = "eyJhbGciOi...")
        String token,

        @Schema(description = "Token expiration in seconds", example = "3600")
        Integer vencimiento,

        @Schema(description = "User data (only when exists=true)")
        DatosUsuarioAuth usuario,

        // solo para 404
        @Schema(description = "Error code (only on not-found)", example = "NO_REGISTRADO")
        String codigo,

        @Schema(description = "Error message (only on not-found)", example = "Usuario no encontrado. Debe registrarse.")
        String mensaje

) {

    public static DatosVerificarAuth noRegistrado() {
        return new DatosVerificarAuth(false, null, null, null, "NO_REGISTRADO",
                "Usuario no encontrado. Debe registrarse.");
    }

    public static DatosVerificarAuth registrado(String token, Integer vencimiento, DatosUsuarioAuth usuario) {
        return new DatosVerificarAuth(true, token, vencimiento, usuario, null, null);
    }
}
