package com.jmcsoft.taco_os.common.helper;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.YaRegistradoException;
import com.jmcsoft.taco_os.domain.producto.Producto;
import com.jmcsoft.taco_os.repository.ProductoRepository;
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
class ProductoHelperTest {

    @Mock
    private ProductoRepository productoRepository;

    @InjectMocks
    private ProductoHelper productoHelper;

    @Test
    @DisplayName("Validar ID nulo lanza NoExisteException")
    void validarIdProducto_idNulo_lanzaExcepcion() {
        assertThrows(NoExisteException.class, () -> productoHelper.validarIdProducto(null));
    }

    @Test
    @DisplayName("Validar ID vacío lanza NoExisteException")
    void validarIdProducto_idVacio_lanzaExcepcion() {
        assertThrows(NoExisteException.class, () -> productoHelper.validarIdProducto(""));
    }

    @Test
    @DisplayName("Validar ID formato inválido lanza NoExisteException")
    void validarIdProducto_formatoInvalido_lanzaExcepcion() {
        assertThrows(NoExisteException.class, () -> productoHelper.validarIdProducto("not-uuid"));
    }

    @Test
    @DisplayName("Validar ID que no existe lanza NoExisteException")
    void validarIdProducto_noExiste_lanzaExcepcion() {
        UUID id = UUID.randomUUID();
        when(productoRepository.findById(id)).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class, () -> productoHelper.validarIdProducto(id.toString()));
    }

    @Test
    @DisplayName("Validar ID existente retorna el producto")
    void validarIdProducto_existe_retornaProducto() {
        UUID id = UUID.randomUUID();
        var prod = new Producto();
        prod.setId(id);
        prod.setNombre("Taco al Pastor");

        when(productoRepository.findById(id)).thenReturn(Optional.of(prod));

        var resultado = productoHelper.validarIdProducto(id.toString());

        assertNotNull(resultado);
        assertEquals("Taco al Pastor", resultado.getNombre());
    }

    @Test
    @DisplayName("Producto ya registrado lanza YaRegistradoException")
    void productoYaRegistrado_yaExiste_lanzaExcepcion() {
        UUID negocioId = UUID.randomUUID();
        when(productoRepository.existsByNombreAndNegocioIdAndActivoTrue("Taco Dup", negocioId)).thenReturn(true);

        assertThrows(YaRegistradoException.class,
                () -> productoHelper.productoYaRegistrado("Taco Dup", negocioId.toString()));
    }

    @Test
    @DisplayName("Producto no registrado no lanza excepción")
    void productoYaRegistrado_noExiste_noLanzaExcepcion() {
        UUID negocioId = UUID.randomUUID();
        when(productoRepository.existsByNombreAndNegocioIdAndActivoTrue("Taco Nuevo", negocioId)).thenReturn(false);

        assertDoesNotThrow(() -> productoHelper.productoYaRegistrado("Taco Nuevo", negocioId.toString()));
    }
}
