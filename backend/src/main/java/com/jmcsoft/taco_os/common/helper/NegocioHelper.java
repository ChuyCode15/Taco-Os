package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NegocioHelper {

    private final NegocioRepository negocioRepository;

    public void negocioYaRegistrado(String nombre) {
        if (negocioRepository.existsByNombreAndActivoTrue(nombre)) {
            throw new com.jmcsoft.taco_os.common.exception.YaExisteException(
                    "Ya existe un negocio registrado con ese nombre",
                    "NegocioHelper.negocioYaRegistrado"
            );
        }
    }

    public Negocio validarIdNegocio(String id) {
        if (id == null || id.isBlank()) {
            throw new IllegalArgumentException("El ID del negocio no puede estar vacío");
        }
        try {
            var uuid = java.util.UUID.fromString(id);
            return negocioRepository.findById(uuid).orElseThrow(() ->
                    new NoExisteException("Negocio no encontrado con ID: " + id,
                            "NegocioHelper.validarIdNegocio"));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("El ID del negocio no tiene formato UUID válido");
        }
    }
}
