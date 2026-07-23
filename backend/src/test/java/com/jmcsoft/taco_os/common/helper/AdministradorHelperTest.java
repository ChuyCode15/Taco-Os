package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.DuplicadoException;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdministradorHelperTest {

    @Mock
    private AdministradorRepository administradorRepository;

    @InjectMocks
    private AdministradorHelper administradorHelper;

    @Test
    @DisplayName("Validar ID nulo lanza IllegalArgumentException")
    void validarIdAdministrador_idNulo_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> administradorHelper.validarIdAdministrador(null));
    }

    @Test
    @DisplayName("Validar ID vacío lanza IllegalArgumentException")
    void validarIdAdministrador_idVacio_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> administradorHelper.validarIdAdministrador(""));
    }

    @Test
    @DisplayName("Validar ID formato inválido lanza IllegalArgumentException")
    void validarIdAdministrador_formatoInvalido_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> administradorHelper.validarIdAdministrador("bad-uuid"));
    }

    @Test
    @DisplayName("Validar ID que no existe lanza NoExisteException")
    void validarIdAdministrador_noExiste_lanzaExcepcion() {
        UUID id = UUID.randomUUID();
        when(administradorRepository.findById(id)).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class, () -> administradorHelper.validarIdAdministrador(id.toString()));
    }

    @Test
    @DisplayName("Validar ID existente retorna el administrador")
    void validarIdAdministrador_existe_retornaAdmin() {
        UUID id = UUID.randomUUID();
        var admin = new Administrador();
        admin.setId(id);
        admin.setNombreCompleto("Juan");

        when(administradorRepository.findById(id)).thenReturn(Optional.of(admin));

        var resultado = administradorHelper.validarIdAdministrador(id.toString());

        assertNotNull(resultado);
        assertEquals("Juan", resultado.getNombreCompleto());
    }

    @Test
    @DisplayName("Google ID ya registrado lanza DuplicadoException")
    void validarGoogleNoRegistrado_yaExiste_lanzaExcepcion() {
        when(administradorRepository.existsByIdGoogle("ggl_dup")).thenReturn(true);

        assertThrows(DuplicadoException.class,
                () -> administradorHelper.validarGoogleNoRegistrado("ggl_dup"));
    }

    @Test
    @DisplayName("Google ID no registrado no lanza excepción")
    void validarGoogleNoRegistrado_noExiste_noLanzaExcepcion() {
        when(administradorRepository.existsByIdGoogle("ggl_new")).thenReturn(false);

        assertDoesNotThrow(() -> administradorHelper.validarGoogleNoRegistrado("ggl_new"));
    }
}
