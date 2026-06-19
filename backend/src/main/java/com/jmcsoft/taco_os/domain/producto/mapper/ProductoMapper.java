package com.jmcsoft.taco_os.domain.producto.mapper;

import com.jmcsoft.taco_os.domain.producto.Producto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProductoMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "activo", ignore = true)
    @Mapping(target = "registro", ignore = true)
    @Mapping(target = "negocio", ignore = true)
    Producto nuevaProducto(DatosRegistroProducto datos);

    @Mapping(target = "id", expression = "java(producto.getId() != null ? producto.getId().toString() : null)")
    DatosDetalleProducto productoADetalle(Producto producto);
}
