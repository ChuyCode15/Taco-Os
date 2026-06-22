package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import com.jmcsoft.taco_os.domain.transaccion.Transaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRegistroTransaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosPago;
import com.jmcsoft.taco_os.domain.transaccion.mapper.TransaccionMapper;
import com.jmcsoft.taco_os.repository.CancelacionRepository;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import com.jmcsoft.taco_os.repository.NotificacionRepository;
import com.jmcsoft.taco_os.repository.TransaccionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransaccionServiceTest {

    @Mock private TransaccionRepository transaccionRepository;
    @Mock private CancelacionRepository cancelacionRepository;
    @Mock private CashierSessionRepository sesionRepository;
    @Mock private NotificacionRepository notificacionRepository;
    @Mock private NegocioHelper negocioHelper;
    @Mock private CajeroHelper cajeroHelper;
    @Mock private TransaccionMapper transaccionMapper;

    @InjectMocks
    private TransaccionService transaccionService;

    @Test
    @DisplayName("Registrar transacción válida retorna respuesta")
    void registrarTransaccion_datosValidos_retornaRespuesta() {
        UUID negocioId = UUID.randomUUID();
        UUID cajeroId = UUID.randomUUID();
        UUID sesionId = UUID.randomUUID();

        var negocio = new Negocio();
        negocio.setId(negocioId);
        var cajero = new Cajero();
        cajero.setId(cajeroId);
        var sesion = new CashierSession();
        sesion.setId(sesionId);

        when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
        when(cajeroHelper.validarIdCajero(cajeroId.toString())).thenReturn(cajero);
        when(sesionRepository.findById(sesionId)).thenReturn(Optional.of(sesion));
        when(transaccionRepository.save(any(Transaccion.class))).thenAnswer(inv -> {
            Transaccion t = inv.getArgument(0);
            t.setId(UUID.randomUUID());
            t.setMarcaTiempo(LocalDateTime.now());
            return t;
        });

        when(transaccionMapper.transaccionARespuesta(any())).thenReturn(
                new com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaTransaccion(
                        "id", "COMPLETADA", "2025-01-01T00:00:00"
                )
        );

        var pago = new DatosPago("EFECTIVO", new BigDecimal("50.00"), new BigDecimal("20.00"), null);
        var datos = new DatosRegistroTransaccion(
                negocioId.toString(), sesionId.toString(), "VENTA",
                cajeroId.toString(), "device-001", "[]", pago,
                new BigDecimal("30.00"), "Venta de prueba"
        );

        var resultado = transaccionService.registrarTransaccion(datos);

        assertNotNull(resultado);
        verify(transaccionRepository).save(any(Transaccion.class));
    }

    @Test
    @DisplayName("Registrar transacción con sesión inexistente lanza excepción")
    void registrarTransaccion_sesionNoExiste_lanzaExcepcion() {
        UUID negocioId = UUID.randomUUID();
        UUID cajeroId = UUID.randomUUID();
        UUID sesionId = UUID.randomUUID();

        var negocio = new Negocio();
        negocio.setId(negocioId);
        var cajero = new Cajero();
        cajero.setId(cajeroId);

        when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
        when(cajeroHelper.validarIdCajero(cajeroId.toString())).thenReturn(cajero);
        when(sesionRepository.findById(sesionId)).thenReturn(Optional.empty());

        var datos = new DatosRegistroTransaccion(
                negocioId.toString(), sesionId.toString(), "VENTA",
                cajeroId.toString(), "device-001", "[]", null,
                new BigDecimal("30.00"), "Venta"
        );

        assertThrows(NoExisteException.class, () -> transaccionService.registrarTransaccion(datos));
    }
}
