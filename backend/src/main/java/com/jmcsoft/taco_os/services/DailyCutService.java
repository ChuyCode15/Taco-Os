package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoCorte;
import com.jmcsoft.taco_os.common.enums.EstadoSesion;
import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.enums.MetodoPago;
import com.jmcsoft.taco_os.common.enums.TipoTransaccion;
import com.jmcsoft.taco_os.common.enums.TipoNotificacion;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.corte.DailyCut;
import com.jmcsoft.taco_os.domain.corte.dto.DatosCierreSesion;
import com.jmcsoft.taco_os.domain.corte.dto.DatosRespuestaCorte;
import com.jmcsoft.taco_os.domain.corte.mapper.DailyCutMapper;
import com.jmcsoft.taco_os.domain.notificacion.Notificacion;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import com.jmcsoft.taco_os.repository.DailyCutRepository;
import com.jmcsoft.taco_os.repository.NotificacionRepository;
import com.jmcsoft.taco_os.repository.TransaccionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DailyCutService {

    private final DailyCutRepository corteRepository;
    private final CashierSessionRepository sesionRepository;
    private final TransaccionRepository transaccionRepository;
    private final NotificacionRepository notificacionRepository;
    private final NegocioHelper negocioHelper;
    private final CajeroHelper cajeroHelper;
    private final DailyCutMapper corteMapper;

    @Transactional
    public DatosRespuestaCorte cerrarSesion(DatosCierreSesion datos) {
        var sesion = sesionRepository.findById(UUID.fromString(datos.sesionId()))
                .orElseThrow(() -> new NoExisteException("Sesión no encontrada", "DailyCutService.cerrarSesion"));

        var totalVentas = transaccionRepository
                .sumBySesionAndTipoAndEstado(sesion.getId(), TipoTransaccion.VENTA, EstadoTransaccion.COMPLETADA);
        var totalGastos = transaccionRepository
                .sumBySesionAndTipoAndEstado(sesion.getId(), TipoTransaccion.GASTO, EstadoTransaccion.COMPLETADA);
        var ventasEfectivo = transaccionRepository
                .sumBySesionAndMetodoAndEstado(sesion.getId(), MetodoPago.EFECTIVO, EstadoTransaccion.COMPLETADA);
        var ventasTarjeta = transaccionRepository
                .sumBySesionAndMetodoAndEstado(sesion.getId(), MetodoPago.TARJETA, EstadoTransaccion.COMPLETADA);

        var efectivoEsperado = sesion.getFondoApertura()
                .add(ventasEfectivo)
                .subtract(totalGastos);
        var diferencia = datos.efectivoReal().subtract(efectivoEsperado);

        EstadoCorte estado;
        if (diferencia.compareTo(BigDecimal.ZERO) == 0) {
            estado = EstadoCorte.OK;
        } else if (diferencia.compareTo(BigDecimal.ZERO) > 0) {
            estado = EstadoCorte.SOBRANTE;
        } else {
            estado = EstadoCorte.FALTANTE;
        }

        var corte = new DailyCut();
        corte.setSesion(sesion);
        corte.setNegocio(sesion.getNegocio());
        corte.setCajero(sesion.getCajero());
        corte.setTotalVentas(totalVentas);
        corte.setTotalGastos(totalGastos);
        corte.setVentasEfectivo(ventasEfectivo);
        corte.setVentasTarjeta(ventasTarjeta);
        corte.setFondoApertura(sesion.getFondoApertura());
        corte.setEfectivoEsperado(efectivoEsperado);
        corte.setEfectivoReal(datos.efectivoReal());
        corte.setDiferencia(diferencia);
        corte.setEstado(estado);
        corte.setNotas(datos.notas());
        corte.setApertura(sesion.getApertura());

        var corteGuardado = corteRepository.save(corte);

        sesion.setEstado(EstadoSesion.CERRADA);
        sesion.setFondoCierre(datos.efectivoReal());
        sesion.setCierre(LocalDateTime.now());
        sesionRepository.save(sesion);

        if (estado != EstadoCorte.OK) {
            var notificacion = new Notificacion();
            notificacion.setNegocio(sesion.getNegocio());
            notificacion.setTipo(TipoNotificacion.DIFERENCIA_CORTE);
            notificacion.setMensaje("Corte con " + estado.name() + ": $" + diferencia.abs());
            notificacion.setDatosJson("{\"cut_id\":\"" + corteGuardado.getId() + "\",\"difference\":" + diferencia + "}");
            notificacionRepository.save(notificacion);
        }

        return corteMapper.corteARespuesta(corteGuardado);
    }
}
