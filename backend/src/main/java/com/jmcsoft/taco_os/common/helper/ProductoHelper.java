package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.YaRegistradoException;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ProductoHelper {

    private final ProductoRepository productoRepository;

    public void productoYaRegistrado(String nombre) {
        if (productoRepository.existsByNombreAndActivoTrue(nombre)) {
            throw new YaRegistradoException(
                "No puede registrar un producto ya registrado",
                "ProductoHelper.productoYaRegistrado"
            );
        }
    }
}
