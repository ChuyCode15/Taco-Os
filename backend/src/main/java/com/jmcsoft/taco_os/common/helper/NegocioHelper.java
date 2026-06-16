package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.YaExisteException;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NegocioHelper {

    private final NegocioRepository negocioRepository;

    public void negocioYaRegistrado(String nombre) {
        if (negocioRepository.existsByNombreAndActivoTrue(nombre)) {
            throw new YaExisteException(
                "Ya existe un negocio registrado con ese nombre",
                "NegocioHelper.negocioYaRegistrado"
            );
        }
    }
}
