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
    Producto nuevaProducto(DatosRegistroProducto datos);

    DatosDetalleProducto productoADetalle(Producto producto);

}
