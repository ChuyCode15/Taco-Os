package com.jmcsoft.taco_os.domain.cajero.mapper;

import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosDetalleCajero;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosListaCajero;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosRegistroCajero;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CajeroMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "negocio", ignore = true)
    @Mapping(target = "activo", ignore = true)
    @Mapping(target = "registro", ignore = true)
    @Mapping(target = "permisos", ignore = true)
    Cajero nuevoCajero(DatosRegistroCajero datos);

    @Mapping(target = "id", expression = "java(cajero.getId() != null ? cajero.getId().toString() : null)")
    @Mapping(target = "negocioId", expression = "java(cajero.getNegocio() != null ? cajero.getNegocio().getId().toString() : null)")
    @Mapping(target = "negocioNombre", expression = "java(cajero.getNegocio() != null ? cajero.getNegocio().getNombre() : null)")
    @Mapping(target = "registro", expression = "java(cajero.getRegistro() != null ? cajero.getRegistro().toString() : null)")
    DatosDetalleCajero cajeroADetalle(Cajero cajero);

    @Mapping(target = "id", expression = "java(cajero.getId() != null ? cajero.getId().toString() : null)")
    @Mapping(target = "tieneSesionAbierta", constant = "false")
    @Mapping(target = "fechaEnlace", expression = "java(cajero.getFechaEnlace() != null ? cajero.getFechaEnlace().toString() : null)")
    DatosListaCajero cajeroALista(Cajero cajero);
}
