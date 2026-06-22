package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.YaExisteException;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.repository.NegocioRepository;
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
class NegocioHelperTest {

    @Mock
    private NegocioRepository negocioRepository;

    @InjectMocks
    private NegocioHelper negocioHelper;

    @Test
    @DisplayName("Validar ID nulo lanza IllegalArgumentException")
    void validarIdNegocio_idNulo_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> negocioHelper.validarIdNegocio(null));
    }

    @Test
    @DisplayName("Validar ID vacío lanza IllegalArgumentException")
    void validarIdNegocio_idVacio_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> negocioHelper.validarIdNegocio(""));
    }

    @Test
    @DisplayName("Validar ID con espacios lanza IllegalArgumentException")
    void validarIdNegocio_idConEspacios_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> negocioHelper.validarIdNegocio("   "));
    }

    @Test
    @DisplayName("Validar ID con formato inválido lanza IllegalArgumentException")
    void validarIdNegocio_formatoInvalido_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> negocioHelper.validarIdNegocio("no-es-uuid"));
    }

    @Test
    @DisplayName("Validar ID que no existe lanza NoExisteException")
    void validarIdNegocio_noExiste_lanzaExcepcion() {
        UUID id = UUID.randomUUID();
        when(negocioRepository.findById(id)).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class, () -> negocioHelper.validarIdNegocio(id.toString()));
    }

    @Test
    @DisplayName("Validar ID existente retorna el negocio")
    void validarIdNegocio_existe_retornaNegocio() {
        UUID id = UUID.randomUUID();
        var negocio = new Negocio();
        negocio.setId(id);
        negocio.setNombre("Tacos Test");

        when(negocioRepository.findById(id)).thenReturn(Optional.of(negocio));

        var resultado = negocioHelper.validarIdNegocio(id.toString());

        assertNotNull(resultado);
        assertEquals("Tacos Test", resultado.getNombre());
    }

    @Test
    @DisplayName("Negocio ya registrado lanza YaExisteException")
    void negocioYaRegistrado_yaExiste_lanzaExcepcion() {
        when(negocioRepository.existsByNombreAndActivoTrue("Tacos Dup")).thenReturn(true);

        assertThrows(YaExisteException.class, () -> negocioHelper.negocioYaRegistrado("Tacos Dup"));
    }

    @Test
    @DisplayName("Negocio no registrado no lanza excepción")
    void negocioYaRegistrado_noExiste_noLanzaExcepcion() {
        when(negocioRepository.existsByNombreAndActivoTrue("Tacos Nuevo")).thenReturn(false);

        assertDoesNotThrow(() -> negocioHelper.negocioYaRegistrado("Tacos Nuevo"));
    }
}
