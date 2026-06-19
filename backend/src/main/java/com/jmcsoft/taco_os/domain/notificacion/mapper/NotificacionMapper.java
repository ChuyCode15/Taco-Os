package com.jmcsoft.taco_os.domain.notificacion.mapper;

import com.jmcsoft.taco_os.common.enums.TipoNotificacion;
import com.jmcsoft.taco_os.domain.notificacion.Notificacion;
import com.jmcsoft.taco_os.domain.notificacion.dto.DatosNotificacion;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NotificacionMapper {

    @Mapping(target = "id", expression = "java(notificacion.getId() != null ? notificacion.getId().toString() : null)")
    @Mapping(target = "tipo", expression = "java(notificacion.getTipo().name())")
    @Mapping(target = "leido", source = "leido")
    @Mapping(target = "registro", expression = "java(notificacion.getRegistro() != null ? notificacion.getRegistro().toString() : null)")
    DatosNotificacion notificacionADatos(Notificacion notificacion);
}
