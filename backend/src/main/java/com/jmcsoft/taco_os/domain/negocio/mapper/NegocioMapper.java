package com.jmcsoft.taco_os.domain.negocio.mapper;

import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NegocioMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "activo", ignore = true)
    @Mapping(target = "creadoEl", ignore = true)
    @Mapping(target = "moneda", ignore = true)
    @Mapping(target = "dineroBase", ignore = true)
    Negocio nuevoNegocio(DatosRegistroNegocio datos);

    @Mapping(target = "creadoEl", expression = "java(negocio.getCreadoEl() != null ? negocio.getCreadoEl().toString() : null)")
    @Mapping(target = "id", expression = "java(negocio.getId() != null ? negocio.getId().toString() : null)")
    DatosDetalleNegocio negocioADetalle(Negocio negocio);
}
