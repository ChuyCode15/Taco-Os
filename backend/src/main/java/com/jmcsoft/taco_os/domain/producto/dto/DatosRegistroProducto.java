package com.jmcsoft.taco_os.domain.producto.dto;

import java.math.BigDecimal;

public record DatosRegistroProducto(

        String nombre,
        BigDecimal precio,
        String categoria,
        String miniVistaUrl

) {
}
