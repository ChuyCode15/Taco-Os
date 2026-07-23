package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.YaRegistradoException;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.common.helper.ProductoHelper;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.producto.Producto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.domain.producto.mapper.ProductoMapper;
import com.jmcsoft.taco_os.repository.ProductoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ProductoService")
class ProductoServiceTest {

    @Mock
    private ProductoRepository productoRepository;
    @Mock
    private ProductoHelper productoHelper;
    @Mock
    private NegocioHelper negocioHelper;
    @Mock
    private ProductoMapper productoMapper;

    @InjectMocks
    private ProductoService productoService;

    private Negocio negocio;
    private Producto producto;
    private DatosRegistroProducto datosRegistro;
    private DatosDetalleProducto datosDetalle;
    private UUID negocioId;
    private UUID productoId;

    @BeforeEach
    void setUp() {
        negocioId = UUID.randomUUID();
        productoId = UUID.randomUUID();

        negocio = new Negocio();
        negocio.setId(negocioId);
        negocio.setNombre("Taquería Test");

        producto = new Producto();
        producto.setId(productoId);
        producto.setNombre("Taco al pastor");
        producto.setPrecio(BigDecimal.valueOf(15));
        producto.setCategoria(Categoria.COMIDA);
        producto.setNegocio(negocio);
        producto.setActivo(true);

        datosRegistro = new DatosRegistroProducto(
                "Taco al pastor",
                BigDecimal.valueOf(15),
                "COMIDA",
                null
        );

        datosDetalle = new DatosDetalleProducto(
                productoId.toString(),
                "Taco al pastor",
                BigDecimal.valueOf(15),
                "COMIDA",
                null
        );
    }

    @Nested
    @DisplayName("crear()")
    class Crear {

        @Test
        @DisplayName("Debería crear un producto correctamente")
        void deberiaCrearProducto() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            when(productoMapper.datosAEntidad(datosRegistro)).thenReturn(producto);
            when(productoRepository.save(any(Producto.class))).thenReturn(producto);
            when(productoMapper.entidadADetalle(producto)).thenReturn(datosDetalle);

            var resultado = productoService.crear(negocioId.toString(), datosRegistro);

            assertThat(resultado).isNotNull();
            assertThat(resultado.nombre()).isEqualTo("Taco al pastor");
            assertThat(resultado.precio()).isEqualByComparingTo(BigDecimal.valueOf(15));
            verify(productoHelper).validarNombreNoDuplicado("Taco al pastor", negocioId.toString());
            verify(productoRepository).save(any(Producto.class));
        }

        @Test
        @DisplayName("Debería lanzar excepción si el nombre ya existe")
        void deberiaLanzarExcepcionSiNombreDuplicado() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            doThrow(new YaRegistradoException("Ya existe", "test"))
                    .when(productoHelper).validarNombreNoDuplicado("Taco al pastor", negocioId.toString());

            assertThatThrownBy(() -> productoService.crear(negocioId.toString(), datosRegistro))
                    .isInstanceOf(YaRegistradoException.class);

            verify(productoRepository, never()).save(any());
        }

        @Test
        @DisplayName("Debería lanzar excepción si el negocio no existe")
        void deberiaLanzarExcepcionSiNegocioNoExiste() {
            when(negocioHelper.validarIdNegocio(negocioId.toString()))
                    .thenThrow(new NoExisteException("Negocio no encontrado", "test"));

            assertThatThrownBy(() -> productoService.crear(negocioId.toString(), datosRegistro))
                    .isInstanceOf(NoExisteException.class);

            verify(productoHelper, never()).validarNombreNoDuplicado(any(), any());
            verify(productoRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("listar()")
    class Listar {

        @Test
        @DisplayName("Debería listar todos los productos del negocio")
        void deberiaListarTodos() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            Page<Producto> page = new PageImpl<>(List.of(producto));
            when(productoRepository.findByNegocioIdAndActivoTrue(eq(negocioId), any(Pageable.class)))
                    .thenReturn(page);
            when(productoMapper.entidadADetalle(producto)).thenReturn(datosDetalle);

            var resultado = productoService.listar(negocioId.toString(), null, PageRequest.of(0, 20));

            assertThat(resultado.getContent()).hasSize(1);
            assertThat(resultado.getContent().get(0).nombre()).isEqualTo("Taco al pastor");
            verify(productoRepository).findByNegocioIdAndActivoTrue(eq(negocioId), any(Pageable.class));
            verify(productoRepository, never()).findByNegocioIdAndCategoriaAndActivoTrue(any(), any(), any());
        }

        @Test
        @DisplayName("Debería filtrar productos por categoría")
        void deberiaFiltrarPorCategoria() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            Page<Producto> page = new PageImpl<>(List.of(producto));
            when(productoRepository.findByNegocioIdAndCategoriaAndActivoTrue(
                    eq(negocioId), eq(Categoria.COMIDA), any(Pageable.class)))
                    .thenReturn(page);
            when(productoMapper.entidadADetalle(producto)).thenReturn(datosDetalle);

            var resultado = productoService.listar(negocioId.toString(), "COMIDA", PageRequest.of(0, 20));

            assertThat(resultado.getContent()).hasSize(1);
            verify(productoRepository).findByNegocioIdAndCategoriaAndActivoTrue(
                    eq(negocioId), eq(Categoria.COMIDA), any(Pageable.class));
            verify(productoRepository, never()).findByNegocioIdAndActivoTrue(any(), any());
        }

        @Test
        @DisplayName("Debería lanzar excepción si categoría no es válida")
        void deberiaLanzarExcepcionSiCategoriaInvalida() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);

            assertThatThrownBy(() -> productoService.listar(negocioId.toString(), "CATEGORIA_INVALIDA", PageRequest.of(0, 20)))
                    .isInstanceOf(IllegalArgumentException.class);
        }
    }

    @Nested
    @DisplayName("detalle()")
    class Detalle {

        @Test
        @DisplayName("Debería retornar el detalle de un producto")
        void deberiaRetornarDetalle() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            when(productoHelper.validarIdProducto(productoId.toString())).thenReturn(producto);
            when(productoMapper.entidadADetalle(producto)).thenReturn(datosDetalle);

            var resultado = productoService.detalle(negocioId.toString(), productoId.toString());

            assertThat(resultado).isNotNull();
            assertThat(resultado.id()).isEqualTo(productoId.toString());
            verify(productoHelper).validarPertenencia(productoId.toString(), negocioId.toString());
        }

        @Test
        @DisplayName("Debería lanzar excepción si el producto no pertenece al negocio")
        void deberiaLanzarExcepcionSiNoPertenece() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            doThrow(new NoExisteException("No pertenece", "test"))
                    .when(productoHelper).validarPertenencia(productoId.toString(), negocioId.toString());

            assertThatThrownBy(() -> productoService.detalle(negocioId.toString(), productoId.toString()))
                    .isInstanceOf(NoExisteException.class);

            verify(productoHelper, never()).validarIdProducto(any());
        }
    }

    @Nested
    @DisplayName("actualizar()")
    class Actualizar {

        @Test
        @DisplayName("Debería actualizar un producto correctamente")
        void deberiaActualizarProducto() {
            var datosActualizados = new DatosRegistroProducto(
                    "Taco de carnitas",
                    BigDecimal.valueOf(18),
                    "COMIDA",
                    "https://photo.jpg"
            );
            var productoActualizado = new Producto();
            productoActualizado.setId(productoId);
            productoActualizado.setNombre("Taco de carnitas");
            productoActualizado.setPrecio(BigDecimal.valueOf(18));
            productoActualizado.setCategoria(Categoria.COMIDA);
            productoActualizado.setFotoUrl("https://photo.jpg");
            productoActualizado.setNegocio(negocio);

            var detalleActualizado = new DatosDetalleProducto(
                    productoId.toString(),
                    "Taco de carnitas",
                    BigDecimal.valueOf(18),
                    "COMIDA",
                    "https://photo.jpg"
            );

            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            when(productoHelper.validarIdProducto(productoId.toString())).thenReturn(producto);
            when(productoRepository.save(any(Producto.class))).thenReturn(productoActualizado);
            when(productoMapper.entidadADetalle(productoActualizado)).thenReturn(detalleActualizado);

            var resultado = productoService.actualizar(negocioId.toString(), productoId.toString(), datosActualizados);

            assertThat(resultado.nombre()).isEqualTo("Taco de carnitas");
            assertThat(resultado.precio()).isEqualByComparingTo(BigDecimal.valueOf(18));
            verify(productoHelper).validarPertenencia(productoId.toString(), negocioId.toString());
            verify(productoRepository).save(any(Producto.class));
        }
    }

    @Nested
    @DisplayName("eliminar()")
    class Eliminar {

        @Test
        @DisplayName("Debería hacer soft delete de un producto")
        void deberiaEliminarProducto() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            when(productoHelper.validarIdProducto(productoId.toString())).thenReturn(producto);

            productoService.eliminar(negocioId.toString(), productoId.toString());

            assertThat(producto.getActivo()).isFalse();
            verify(productoRepository).save(producto);
        }

        @Test
        @DisplayName("Debería lanzar excepción si el producto no existe")
        void deberiaLanzarExcepcionSiProductoNoExiste() {
            when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
            when(productoHelper.validarIdProducto(productoId.toString()))
                    .thenThrow(new NoExisteException("No encontrado", "test"));

            assertThatThrownBy(() -> productoService.eliminar(negocioId.toString(), productoId.toString()))
                    .isInstanceOf(NoExisteException.class);

            verify(productoRepository, never()).save(any());
        }
    }
}
