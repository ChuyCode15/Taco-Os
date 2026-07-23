package com.jmcsoft.taco_os.domain.sesioncajero.mapper;

import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosDetalleSesion;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CashierSessionMapper {

    @Mapping(target = "id", expression = "java(sesion.getId() != null ? sesion.getId().toString() : null)")
    @Mapping(target = "sessionId", expression = "java(sesion.getId() != null ? sesion.getId().toString() : null)")
    @Mapping(target = "estado", expression = "java(sesion.getEstado().name())")
    @Mapping(target = "apertura", expression = "java(sesion.getApertura() != null ? sesion.getApertura().toString() : null)")
    DatosDetalleSesion sesionADetalle(CashierSession sesion);
}
