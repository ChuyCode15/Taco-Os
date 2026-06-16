package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ProductoHelper {

    private final ProductoRepository productoRepository;

    public void productoYaRegistrado(String nombre) {
        if(productoRepository.findByNombreAndActivoTrue(nombre)){
            throw new DuplicateKeyException("No puede registrar un producto ya registrado");
        }
    }
}
