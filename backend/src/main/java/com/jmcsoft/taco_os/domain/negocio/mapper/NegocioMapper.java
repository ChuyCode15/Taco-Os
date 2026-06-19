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
    @Mapping(target = "registro", ignore = true)
    @Mapping(target = "moneda", ignore = true)
    @Mapping(target = "empleados", source = "empleados")
    Negocio nuevoNegocio(DatosRegistroNegocio datos);

    @Mapping(target = "id", expression = "java(negocio.getId() != null ? negocio.getId().toString() : null)")
    @Mapping(target = "registro", expression = "java(negocio.getRegistro() != null ? negocio.getRegistro().toString() : null)")
    DatosDetalleNegocio negocioADetalle(Negocio negocio);
}
