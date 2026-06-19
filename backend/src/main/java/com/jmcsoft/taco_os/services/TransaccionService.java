package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.enums.MetodoPago;
import com.jmcsoft.taco_os.common.enums.TipoTransaccion;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.NoAutorizadoException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.cancelacion.Cancelacion;
import com.jmcsoft.taco_os.domain.transaccion.Transaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosCancelacion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRegistroTransaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaCancelacion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaTransaccion;
import com.jmcsoft.taco_os.domain.transaccion.mapper.TransaccionMapper;
import com.jmcsoft.taco_os.domain.notificacion.Notificacion;
import com.jmcsoft.taco_os.common.enums.TipoNotificacion;
import com.jmcsoft.taco_os.repository.CancelacionRepository;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import com.jmcsoft.taco_os.repository.NotificacionRepository;
import com.jmcsoft.taco_os.repository.TransaccionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TransaccionService {

    private final TransaccionRepository transaccionRepository;
    private final CancelacionRepository cancelacionRepository;
    private final CashierSessionRepository sesionRepository;
    private final NotificacionRepository notificacionRepository;
    private final NegocioHelper negocioHelper;
    private final CajeroHelper cajeroHelper;
    private final TransaccionMapper transaccionMapper;

    @Transactional
    public DatosRespuestaTransaccion registrarTransaccion(DatosRegistroTransaccion datos) {
        var negocio = negocioHelper.validarIdNegocio(datos.negocioId());
        var cajero = cajeroHelper.validarIdCajero(datos.cajeroId());
        var sesion = sesionRepository.findById(UUID.fromString(datos.sesionId()))
                .orElseThrow(() -> new NoExisteException("Sesión no encontrada", "TransaccionService.registrarTransaccion"));

        var transaccion = new Transaccion();
        transaccion.setNegocio(negocio);
        transaccion.setSesion(sesion);
        transaccion.setTipo(TipoTransaccion.valueOf(datos.tipo().toUpperCase()));
        transaccion.setCajero(cajero);
        transaccion.setDispositivoId(datos.dispositivoId());
        transaccion.setItemsJson(datos.itemsJson());
        transaccion.setTotal(datos.total());
        transaccion.setDescripcion(datos.descripcion());
        transaccion.setEstado(EstadoTransaccion.COMPLETADA);

        if (datos.pago() != null) {
            transaccion.setMetodoPago(MetodoPago.valueOf(datos.pago().metodo().toUpperCase()));
            transaccion.setMontoRecibido(datos.pago().montoRecibido());
            transaccion.setCambio(datos.pago().cambio());
            transaccion.setFotoBaucher(datos.pago().fotoBaucher());
        }

        var guardada = transaccionRepository.save(transaccion);
        return transaccionMapper.transaccionARespuesta(guardada);
    }

    @Transactional
    public DatosRespuestaCancelacion cancelarTransaccion(String transaccionId, DatosCancelacion datos) {
        var transaccion = transaccionRepository.findById(UUID.fromString(transaccionId))
                .orElseThrow(() -> new NoExisteException("Transacción no encontrada", "TransaccionService.cancelarTransaccion"));

        if (Duration.between(transaccion.getMarcaTiempo(), LocalDateTime.now()).toMinutes() > 5) {
            throw new NoAutorizadoException(
                    "Fuera de la ventana de cancelación (5 minutos)",
                    "TransaccionService.cancelarTransaccion"
            );
        }

        transaccion.setEstado(EstadoTransaccion.CANCELADA);
        transaccionRepository.save(transaccion);

        var cancelacion = new Cancelacion();
        cancelacion.setTransaccion(transaccion);
        cancelacion.setCajero(transaccion.getCajero());
        cancelacion.setMotivo(datos.motivo());
        cancelacion.setFotoUrl(datos.fotoUrl());
        cancelacionRepository.save(cancelacion);

        var notificacion = new Notificacion();
        notificacion.setNegocio(transaccion.getNegocio());
        notificacion.setTipo(TipoNotificacion.CANCELACION);
        notificacion.setMensaje("Cancelación registrada. Motivo: " + datos.motivo());
        notificacion.setDatosJson("{\"transaction_id\":\"" + transaccionId + "\",\"amount\":" + transaccion.getTotal() + "}");
        notificacionRepository.save(notificacion);

        return new DatosRespuestaCancelacion(
                "cancelled",
                transaccion.getTotal(),
                cancelacion.getCanceladoEn().toString(),
                true
        );
    }
}
