package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoSesion;
import com.jmcsoft.taco_os.common.exception.YaExisteException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosAperturaSesion;
import com.jmcsoft.taco_os.domain.sesioncajero.mapper.CashierSessionMapper;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CashierSessionServiceTest {

    @Mock private CashierSessionRepository sesionRepository;
    @Mock private NegocioHelper negocioHelper;
    @Mock private CajeroHelper cajeroHelper;
    @Mock private CashierSessionMapper sesionMapper;

    @InjectMocks
    private CashierSessionService sesionService;

    @Test
    @DisplayName("Abrir sesión sin sesión abierta previa retorna detalle")
    void abrirSesion_sinSesionAbierta_retornaDetalle() {
        UUID negocioId = UUID.randomUUID();
        UUID cajeroId = UUID.randomUUID();

        var negocio = new Negocio();
        negocio.setId(negocioId);
        var cajero = new Cajero();
        cajero.setId(cajeroId);

        when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
        when(cajeroHelper.validarIdCajero(cajeroId.toString())).thenReturn(cajero);
        when(sesionRepository.findByNegocioIdAndCajeroIdAndEstado(negocioId, cajeroId, EstadoSesion.ABIERTA))
                .thenReturn(Optional.empty());
        when(sesionRepository.save(any(CashierSession.class))).thenAnswer(inv -> {
            CashierSession s = inv.getArgument(0);
            s.setId(UUID.randomUUID());
            return s;
        });

        when(sesionMapper.sesionADetalle(any())).thenReturn(
                new com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosDetalleSesion(
                        "id", "session-id", "ABIERTA", "2025-01-01", new BigDecimal("500.00")
                )
        );

        var datos = new DatosAperturaSesion(negocioId.toString(), cajeroId.toString(), "device-001", new BigDecimal("500.00"));
        var resultado = sesionService.abrirSesion(datos);

        assertNotNull(resultado);
        verify(sesionRepository).save(any(CashierSession.class));
    }

    @Test
    @DisplayName("Abrir sesión con sesión abierta previa lanza YaExisteException")
    void abrirSesion_conSesionAbierta_lanzaExcepcion() {
        UUID negocioId = UUID.randomUUID();
        UUID cajeroId = UUID.randomUUID();

        var negocio = new Negocio();
        negocio.setId(negocioId);
        var cajero = new Cajero();
        cajero.setId(cajeroId);
        var sesionExistente = new CashierSession();
        sesionExistente.setId(UUID.randomUUID());

        when(negocioHelper.validarIdNegocio(negocioId.toString())).thenReturn(negocio);
        when(cajeroHelper.validarIdCajero(cajeroId.toString())).thenReturn(cajero);
        when(sesionRepository.findByNegocioIdAndCajeroIdAndEstado(negocioId, cajeroId, EstadoSesion.ABIERTA))
                .thenReturn(Optional.of(sesionExistente));

        var datos = new DatosAperturaSesion(negocioId.toString(), cajeroId.toString(), "device-001", new BigDecimal("500.00"));

        assertThrows(YaExisteException.class, () -> sesionService.abrirSesion(datos));
    }
}
