package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AdministradorHelper {

    private final AdministradorRepository administradorRepository;

    public void validarGoogleNoRegistrado(String idGoogle) {
        if (administradorRepository.existsByIdGoogle(idGoogle)) {
            throw new com.jmcsoft.taco_os.common.exception.DuplicadoException(
                    "El administrador con Google ID " + idGoogle + " ya está registrado",
                    "AdministradorHelper.validarGoogleNoRegistrado"
            );
        }
    }

    public Administrador validarIdAdministrador(String id) {
        if (id == null || id.isBlank()) {
            throw new IllegalArgumentException("El ID del administrador no puede estar vacío");
        }
        try {
            var uuid = java.util.UUID.fromString(id);
            return administradorRepository.findById(uuid).orElseThrow(() ->
                    new NoExisteException("Administrador no encontrado con ID: " + id,
                            "AdministradorHelper.validarIdAdministrador"));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("El ID del administrador no tiene formato UUID válido");
        }
    }
}
