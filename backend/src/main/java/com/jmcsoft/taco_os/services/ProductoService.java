package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.common.helper.ProductoHelper;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.domain.producto.mapper.ProductoMapper;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final ProductoHelper productoHelper;
    private final NegocioHelper negocioHelper;
    private final ProductoMapper productoMapper;

    @Transactional
    public DatosDetalleProducto registrarProducto(String negocioId, DatosRegistroProducto datos) {
        var negocio = negocioHelper.validarIdNegocio(negocioId);
        productoHelper.productoYaRegistrado(datos.nombre(), negocioId);

        var productoNuevo = productoMapper.nuevaProducto(datos);
        productoNuevo.setNegocio(negocio);
        var producto = productoRepository.save(productoNuevo);

        return productoMapper.productoADetalle(producto);
    }

    @Transactional(readOnly = true)
    public List<DatosDetalleProducto> listarProductos(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        return productoRepository.findByNegocioIdAndActivoTrue(java.util.UUID.fromString(negocioId))
                .stream()
                .map(productoMapper::productoADetalle)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<DatosDetalleProducto> listarPorCategoria(String negocioId, String categoria) {
        negocioHelper.validarIdNegocio(negocioId);

        var cat = Categoria.valueOf(categoria.toUpperCase());
        return productoRepository.findByNegocioIdAndCategoriaAndActivoTrue(java.util.UUID.fromString(negocioId), cat)
                .stream()
                .map(productoMapper::productoADetalle)
                .collect(Collectors.toList());
    }

    @Transactional
    public DatosDetalleProducto editarProducto(String negocioId, String productoId, DatosRegistroProducto datos) {
        negocioHelper.validarIdNegocio(negocioId);
        var producto = productoHelper.validarIdProducto(productoId);

        producto.setNombre(datos.nombre());
        producto.setPrecio(datos.precio());
        producto.setCategoria(Categoria.valueOf(datos.categoria().toUpperCase()));
        producto.setFotoUrl(datos.fotoUrl());

        var productoActualizado = productoRepository.save(producto);
        return productoMapper.productoADetalle(productoActualizado);
    }

    @Transactional
    public void eliminarProducto(String negocioId, String productoId) {
        negocioHelper.validarIdNegocio(negocioId);
        var producto = productoHelper.validarIdProducto(productoId);

        producto.setActivo(false);
        productoRepository.save(producto);
    }
}
