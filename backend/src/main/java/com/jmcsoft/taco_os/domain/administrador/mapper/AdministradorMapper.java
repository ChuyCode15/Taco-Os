package com.jmcsoft.taco_os.domain.administrador.mapper;

import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.domain.administrador.dto.DatosDetalleAdmin;
import com.jmcsoft.taco_os.domain.administrador.dto.DatosListaAdmin;
import com.jmcsoft.taco_os.domain.administrador.dto.DatosRegistroAdmin;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AdministradorMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "negocio", ignore = true)
    @Mapping(target = "activo", ignore = true)
    @Mapping(target = "registro", ignore = true)
    @Mapping(target = "tipoPlan", ignore = true)
    @Mapping(target = "estadoPlan", ignore = true)
    @Mapping(target = "fechaVencimiento", ignore = true)
    Administrador nuevoAdministrador(DatosRegistroAdmin datos);

    @Mapping(target = "id", expression = "java(admin.getId() != null ? admin.getId().toString() : null)")
    @Mapping(target = "negocioId", expression = "java(admin.getNegocio() != null ? admin.getNegocio().getId().toString() : null)")
    @Mapping(target = "negocioNombre", expression = "java(admin.getNegocio() != null ? admin.getNegocio().getNombre() : null)")
    @Mapping(target = "tipoPlan", expression = "java(admin.getTipoPlan() != null ? admin.getTipoPlan().name() : null)")
    @Mapping(target = "estadoPlan", expression = "java(admin.getEstadoPlan() != null ? admin.getEstadoPlan().name() : null)")
    @Mapping(target = "fechaVencimiento", expression = "java(admin.getFechaVencimiento() != null ? admin.getFechaVencimiento().toString() : null)")
    @Mapping(target = "registro", expression = "java(admin.getRegistro() != null ? admin.getRegistro().toString() : null)")
    DatosDetalleAdmin adminADetalle(Administrador admin);

    @Mapping(target = "id", expression = "java(admin.getId() != null ? admin.getId().toString() : null)")
    @Mapping(target = "tipoPlan", expression = "java(admin.getTipoPlan() != null ? admin.getTipoPlan().name() : null)")
    @Mapping(target = "estadoPlan", expression = "java(admin.getEstadoPlan() != null ? admin.getEstadoPlan().name() : null)")
    DatosListaAdmin adminALista(Administrador admin);
}
