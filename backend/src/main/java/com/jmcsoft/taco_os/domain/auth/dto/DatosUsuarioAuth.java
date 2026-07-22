package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "User authentication data")
public record DatosUsuarioAuth(
        String id,
        @JsonProperty("idGoogle") String idGoogle,
        String nickname,
        String correo,
        String rol,
        @JsonProperty("tieneNegocio") Boolean tieneNegocio,
        String negocioId,
        String negocioNombre
) {}
