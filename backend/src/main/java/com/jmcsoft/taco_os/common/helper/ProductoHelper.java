package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.YaRegistradoException;
import com.jmcsoft.taco_os.domain.producto.Producto;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class ProductoHelper {

    private final ProductoRepository productoRepository;

    public void validarNombreNoDuplicado(String nombre, String negocioId) {
        if (productoRepository.existsByNombreAndNegocioIdAndActivoTrue(nombre, UUID.fromString(negocioId))) {
            throw new YaRegistradoException(
                    "Ya existe un producto con ese nombre en este negocio",
                    "ProductoHelper.validarNombreNoDuplicado"
            );
        }
    }

    public Producto validarIdProducto(String id) {
        if (id == null || id.isBlank()) {
            throw new NoExisteException(
                    "El id del producto no puede estar vacío",
                    "ProductoHelper.validarIdProducto"
            );
        }
        try {
            UUID.fromString(id);
        } catch (IllegalArgumentException e) {
            throw new NoExisteException(
                    "El id del producto no es válido",
                    "ProductoHelper.validarIdProducto"
            );
        }
        return productoRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException(
                        "Producto no encontrado",
                        "ProductoHelper.validarIdProducto"
                ));
    }

    public void validarPertenencia(String productoId, String negocioId) {
        if (!productoRepository.existsByIdAndNegocioId(
                UUID.fromString(productoId), UUID.fromString(negocioId))) {
            throw new NoExisteException(
                    "El producto no pertenece a este negocio",
                    "ProductoHelper.validarPertenencia"
            );
        }
    }
}
