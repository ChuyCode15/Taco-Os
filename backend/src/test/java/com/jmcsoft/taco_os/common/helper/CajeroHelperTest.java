package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.repository.CajeroRepository;
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
class CajeroHelperTest {

    @Mock
    private CajeroRepository cajeroRepository;

    @InjectMocks
    private CajeroHelper cajeroHelper;

    @Test
    @DisplayName("Validar ID nulo lanza IllegalArgumentException")
    void validarIdCajero_idNulo_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> cajeroHelper.validarIdCajero(null));
    }

    @Test
    @DisplayName("Validar ID vacío lanza IllegalArgumentException")
    void validarIdCajero_idVacio_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> cajeroHelper.validarIdCajero(""));
    }

    @Test
    @DisplayName("Validar ID formato inválido lanza IllegalArgumentException")
    void validarIdCajero_formatoInvalido_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> cajeroHelper.validarIdCajero("invalid-uuid"));
    }

    @Test
    @DisplayName("Validar ID que no existe lanza NoExisteException")
    void validarIdCajero_noExiste_lanzaExcepcion() {
        UUID id = UUID.randomUUID();
        when(cajeroRepository.findById(id)).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class, () -> cajeroHelper.validarIdCajero(id.toString()));
    }

    @Test
    @DisplayName("Validar ID existente retorna el cajero")
    void validarIdCajero_existe_retornaCajero() {
        UUID id = UUID.randomUUID();
        var cajero = new Cajero();
        cajero.setId(id);
        cajero.setNombreCompleto("Pedro");

        when(cajeroRepository.findById(id)).thenReturn(Optional.of(cajero));

        var resultado = cajeroHelper.validarIdCajero(id.toString());

        assertNotNull(resultado);
        assertEquals("Pedro", resultado.getNombreCompleto());
    }

    @Test
    @DisplayName("Google ID ya registrado lanza DuplicadoException")
    void validarGoogleNoRegistrado_yaExiste_lanzaExcepcion() {
        when(cajeroRepository.existsByIdGoogle("ggl_dup")).thenReturn(true);

        assertThrows(com.jmcsoft.taco_os.common.exception.DuplicadoException.class,
                () -> cajeroHelper.validarGoogleNoRegistrado("ggl_dup"));
    }

    @Test
    @DisplayName("Google ID no registrado no lanza excepción")
    void validarGoogleNoRegistrado_noExiste_noLanzaExcepcion() {
        when(cajeroRepository.existsByIdGoogle("ggl_new")).thenReturn(false);

        assertDoesNotThrow(() -> cajeroHelper.validarGoogleNoRegistrado("ggl_new"));
    }
}
