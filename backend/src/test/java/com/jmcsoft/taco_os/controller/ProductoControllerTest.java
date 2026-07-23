package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.services.ProductoService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.net.URI;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ProductoController")
class ProductoControllerTest {

    @Mock
    private ProductoService productoService;

    @InjectMocks
    private ProductoController controller;

    private String negocioId;
    private String productoId;
    private DatosRegistroProducto datosRegistro;
    private DatosDetalleProducto datosDetalle;

    @BeforeEach
    void setUp() {
        negocioId = UUID.randomUUID().toString();
        productoId = UUID.randomUUID().toString();

        datosRegistro = new DatosRegistroProducto(
                "Taco al pastor",
                BigDecimal.valueOf(15),
                "COMIDA",
                null
        );

        datosDetalle = new DatosDetalleProducto(
                productoId,
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
        @DisplayName("Debería retornar 201 con Location y body")
        void deberiaCrearProducto() {
            when(productoService.crear(eq(negocioId), any(DatosRegistroProducto.class)))
                    .thenReturn(datosDetalle);

            var response = controller.crear(negocioId, datosRegistro, mockUriBuilder());

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().nombre()).isEqualTo("Taco al pastor");
            assertThat(response.getBody().precio()).isEqualByComparingTo(BigDecimal.valueOf(15));
            assertThat(response.getHeaders().getLocation()).isNotNull();
            verify(productoService).crear(eq(negocioId), any(DatosRegistroProducto.class));
        }
    }

    @Nested
    @DisplayName("listar()")
    class Listar {

        @Test
        @DisplayName("Debería retornar página de productos")
        void deberiaListarProductos() {
            var page = new PageImpl<>(List.of(datosDetalle), PageRequest.of(0, 20), 1);
            when(productoService.listar(eq(negocioId), eq(null), any(PageRequest.class)))
                    .thenReturn(page);

            var response = controller.listar(negocioId, null, PageRequest.of(0, 20));

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().getContent()).hasSize(1);
            assertThat(response.getBody().getContent().get(0).nombre()).isEqualTo("Taco al pastor");
        }

        @Test
        @DisplayName("Debería filtrar por categoría")
        void deberiaFiltrarPorCategoria() {
            var page = new PageImpl<>(List.of(datosDetalle), PageRequest.of(0, 20), 1);
            when(productoService.listar(eq(negocioId), eq("COMIDA"), any(PageRequest.class)))
                    .thenReturn(page);

            var response = controller.listar(negocioId, "COMIDA", PageRequest.of(0, 20));

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody().getContent()).hasSize(1);
            verify(productoService).listar(eq(negocioId), eq("COMIDA"), any(PageRequest.class));
        }
    }

    @Nested
    @DisplayName("detalle()")
    class Detalle {

        @Test
        @DisplayName("Debería retornar detalle del producto")
        void deberiaRetornarDetalle() {
            when(productoService.detalle(negocioId, productoId)).thenReturn(datosDetalle);

            var response = controller.detalle(negocioId, productoId);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().id()).isEqualTo(productoId);
            assertThat(response.getBody().nombre()).isEqualTo("Taco al pastor");
        }
    }

    @Nested
    @DisplayName("actualizar()")
    class Actualizar {

        @Test
        @DisplayName("Debería actualizar y retornar el producto")
        void deberiaActualizarProducto() {
            var datosActualizados = new DatosRegistroProducto(
                    "Taco de carnitas",
                    BigDecimal.valueOf(18),
                    "COMIDA",
                    "https://photo.jpg"
            );
            var detalleActualizado = new DatosDetalleProducto(
                    productoId,
                    "Taco de carnitas",
                    BigDecimal.valueOf(18),
                    "COMIDA",
                    "https://photo.jpg"
            );

            when(productoService.actualizar(eq(negocioId), eq(productoId), any(DatosRegistroProducto.class)))
                    .thenReturn(detalleActualizado);

            var response = controller.actualizar(negocioId, productoId, datosActualizados);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody().nombre()).isEqualTo("Taco de carnitas");
            assertThat(response.getBody().precio()).isEqualByComparingTo(BigDecimal.valueOf(18));
            verify(productoService).actualizar(eq(negocioId), eq(productoId), any(DatosRegistroProducto.class));
        }
    }

    @Nested
    @DisplayName("eliminar()")
    class Eliminar {

        @Test
        @DisplayName("Debería retornar 204 sin body")
        void deberiaEliminarProducto() {
            doNothing().when(productoService).eliminar(negocioId, productoId);

            var response = controller.eliminar(negocioId, productoId);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
            assertThat(response.getBody()).isNull();
            verify(productoService).eliminar(negocioId, productoId);
        }
    }

    private org.springframework.web.util.UriComponentsBuilder mockUriBuilder() {
        return org.springframework.web.util.UriComponentsBuilder.fromPath("/api/v1");
    }
}
