package com.jmcsoft.taco_os.domain.master.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Login request for Control Maestro")
public record DatosLoginMaster(
        @Schema(description = "Username", example = "jesus")
        String username,
        @Schema(description = "Password", example = "dev123")
        String password
) {}
