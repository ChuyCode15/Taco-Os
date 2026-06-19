package com.jmcsoft.taco_os.domain.superusuario.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Login request for SuperUser")
public record DatosLoginSuperSu(
        @Schema(description = "Username", example = "SuperSu")
        String username,

        @Schema(description = "Password", example = "AdminSu")
        String password
) {}
