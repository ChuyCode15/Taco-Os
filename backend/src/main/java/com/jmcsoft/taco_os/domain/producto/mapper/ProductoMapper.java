package com.jmcsoft.taco_os.domain.producto.mapper;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.domain.producto.Producto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface ProductoMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "activo", ignore = true)
    @Mapping(target = "registro", ignore = true)
    @Mapping(target = "negocio", ignore = true)
    @Mapping(target = "categoria", expression = "java(com.jmcsoft.taco_os.common.enums.Categoria.valueOf(datos.categoria().toUpperCase()))")
    Producto datosAEntidad(DatosRegistroProducto datos);

    @Mapping(target = "id", expression = "java(producto.getId() != null ? producto.getId().toString() : null)")
    @Mapping(target = "categoria", expression = "java(producto.getCategoria() != null ? producto.getCategoria().name() : null)")
    DatosDetalleProducto entidadADetalle(Producto producto);
}
