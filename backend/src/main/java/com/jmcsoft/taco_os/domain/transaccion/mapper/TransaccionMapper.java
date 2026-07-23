package com.jmcsoft.taco_os.domain.transaccion.mapper;

import com.jmcsoft.taco_os.domain.transaccion.Transaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaTransaccion;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TransaccionMapper {

    @Mapping(target = "id", expression = "java(transaccion.getId() != null ? transaccion.getId().toString() : null)")
    @Mapping(target = "estado", expression = "java(transaccion.getEstado().name())")
    @Mapping(target = "marcaTiempo", expression = "java(transaccion.getMarcaTiempo() != null ? transaccion.getMarcaTiempo().toString() : null)")
    DatosRespuestaTransaccion transaccionARespuesta(Transaccion transaccion);
}
