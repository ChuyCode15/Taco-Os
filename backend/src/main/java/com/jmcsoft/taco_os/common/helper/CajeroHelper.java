package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CajeroHelper {

    private final CajeroRepository cajeroRepository;

    public void validarGoogleNoRegistrado(String idGoogle) {
        if (cajeroRepository.existsByIdGoogle(idGoogle)) {
            throw new com.jmcsoft.taco_os.common.exception.DuplicadoException(
                    "El cajero con Google ID " + idGoogle + " ya está registrado",
                    "CajeroHelper.validarGoogleNoRegistrado"
            );
        }
    }

    public Cajero validarIdCajero(String id) {
        if (id == null || id.isBlank()) {
            throw new IllegalArgumentException("El ID del cajero no puede estar vacío");
        }
        try {
            var uuid = java.util.UUID.fromString(id);
            return cajeroRepository.findById(uuid).orElseThrow(() ->
                    new NoExisteException("Cajero no encontrado con ID: " + id,
                            "CajeroHelper.validarIdCajero"));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("El ID del cajero no tiene formato UUID válido");
        }
    }
}
