package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.common.helper.ProductoHelper;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.domain.producto.mapper.ProductoMapper;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final ProductoHelper productoHelper;
    private final NegocioHelper negocioHelper;
    private final ProductoMapper productoMapper;

    @Transactional
    public DatosDetalleProducto crear(String negocioId, DatosRegistroProducto datos) {
        var negocio = negocioHelper.validarIdNegocio(negocioId);
        productoHelper.validarNombreNoDuplicado(datos.nombre(), negocioId);

        var producto = productoMapper.datosAEntidad(datos);
        producto.setNegocio(negocio);
        var guardado = productoRepository.save(producto);

        return productoMapper.entidadADetalle(guardado);
    }

    @Transactional(readOnly = true)
    public Page<DatosDetalleProducto> listar(String negocioId, String categoria, Pageable pageable) {
        negocioHelper.validarIdNegocio(negocioId);
        var negocioUuid = java.util.UUID.fromString(negocioId);

        if (categoria != null) {
            var cat = Categoria.valueOf(categoria.toUpperCase());
            return productoRepository
                    .findByNegocioIdAndCategoriaAndActivoTrue(negocioUuid, cat, pageable)
                    .map(productoMapper::entidadADetalle);
        }

        return productoRepository
                .findByNegocioIdAndActivoTrue(negocioUuid, pageable)
                .map(productoMapper::entidadADetalle);
    }

    @Transactional(readOnly = true)
    public DatosDetalleProducto detalle(String negocioId, String productoId) {
        negocioHelper.validarIdNegocio(negocioId);
        productoHelper.validarPertenencia(productoId, negocioId);
        var producto = productoHelper.validarIdProducto(productoId);
        return productoMapper.entidadADetalle(producto);
    }

    @Transactional
    public DatosDetalleProducto actualizar(String negocioId, String productoId, DatosRegistroProducto datos) {
        negocioHelper.validarIdNegocio(negocioId);
        productoHelper.validarPertenencia(productoId, negocioId);
        var producto = productoHelper.validarIdProducto(productoId);

        producto.setNombre(datos.nombre());
        producto.setPrecio(datos.precio());
        producto.setCategoria(Categoria.valueOf(datos.categoria().toUpperCase()));
        producto.setFotoUrl(datos.fotoUrl());

        var actualizado = productoRepository.save(producto);
        return productoMapper.entidadADetalle(actualizado);
    }

    @Transactional
    public void eliminar(String negocioId, String productoId) {
        negocioHelper.validarIdNegocio(negocioId);
        productoHelper.validarPertenencia(productoId, negocioId);
        var producto = productoHelper.validarIdProducto(productoId);

        producto.setActivo(false);
        productoRepository.save(producto);
    }
}
