package com.jmcsoft.taco_os.common.dto;

public record DatosError(

        String codigo,
        String mensaje,
        String ubicacion,
        Integer status

) {
}
