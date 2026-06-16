package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.helper.ProductoHelper;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.domain.producto.mapper.ProductoMapper;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final ProductoHelper productoHelper;
    private final ProductoMapper productoMapper;


    public DatosDetalleProducto registrarProducto(DatosRegistroProducto datos) {
        productoHelper.productoYaRegistrado(datos.nombre());

        var productoNuevo = productoMapper.nuevaProducto(datos);
        var producto = productoRepository.save(productoNuevo);

        return productoMapper.productoADetalle(producto);
    }
}
