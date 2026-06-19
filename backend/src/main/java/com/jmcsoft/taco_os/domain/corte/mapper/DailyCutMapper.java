package com.jmcsoft.taco_os.domain.corte.mapper;

import com.jmcsoft.taco_os.domain.corte.DailyCut;
import com.jmcsoft.taco_os.domain.corte.dto.DatosRespuestaCorte;
import com.jmcsoft.taco_os.domain.corte.dto.DatosResumen;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface DailyCutMapper {

    @Mapping(target = "corteId", expression = "java(corte.getId() != null ? corte.getId().toString() : null)")
    @Mapping(target = "sesionId", expression = "java(corte.getSesion() != null ? corte.getSesion().getId().toString() : null)")
    @Mapping(target = "apertura", expression = "java(corte.getApertura() != null ? corte.getApertura().toString() : null)")
    @Mapping(target = "cierre", expression = "java(corte.getCierre() != null ? corte.getCierre().toString() : null)")
    @Mapping(target = "estado", expression = "java(corte.getEstado().name())")
    @Mapping(target = "ticketUrl", ignore = true)
    @Mapping(target = "resumen", expression = "java(crearResumen(corte))")
    DatosRespuestaCorte corteARespuesta(DailyCut corte);

    default DatosResumen crearResumen(DailyCut corte) {
        return new DatosResumen(
                corte.getTotalVentas(),
                corte.getTotalGastos(),
                corte.getVentasEfectivo(),
                corte.getVentasTarjeta(),
                corte.getFondoApertura(),
                corte.getEfectivoEsperado(),
                corte.getEfectivoReal(),
                corte.getDiferencia()
        );
    }
}
