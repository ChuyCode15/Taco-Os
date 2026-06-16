package com.jmcsoft.taco_os.domain.negocio.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record DatosDetalleNegocio(

        String id,
        String nombre,
        String ubicacion,
        String horaCierre,
        String moneda,
        BigDecimal dineroBase,
        String creadoEl

) {
}
