package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.notificacion.Notificacion;
import com.jmcsoft.taco_os.domain.notificacion.dto.DatosListaNotificaciones;
import com.jmcsoft.taco_os.domain.notificacion.dto.DatosNotificacion;
import com.jmcsoft.taco_os.domain.notificacion.mapper.NotificacionMapper;
import com.jmcsoft.taco_os.repository.NotificacionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificacionService {

    private final NotificacionRepository notificacionRepository;
    private final NegocioHelper negocioHelper;
    private final NotificacionMapper notificacionMapper;

    @Transactional(readOnly = true)
    public DatosListaNotificaciones listarNotificaciones(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        var notificaciones = notificacionRepository
                .findByNegocioIdOrderByRegistroDesc(UUID.fromString(negocioId))
                .stream()
                .map(notificacionMapper::notificacionADatos)
                .collect(Collectors.toList());

        return new DatosListaNotificaciones(notificaciones);
    }

    @Transactional
    public void marcarLeida(String negocioId, String notificacionId) {
        negocioHelper.validarIdNegocio(negocioId);

        var notificacion = notificacionRepository.findById(UUID.fromString(notificacionId))
                .orElseThrow(() -> new NoExisteException(
                        "Notificación no encontrada",
                        "NotificacionService.marcarLeida"
                ));
        notificacion.setLeido(true);
        notificacionRepository.save(notificacion);
    }

    @Transactional
    public void marcarTodasLeidas(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        var noLeidas = notificacionRepository
                .findByNegocioIdAndLeidoFalse(UUID.fromString(negocioId));
        noLeidas.forEach(n -> n.setLeido(true));
        notificacionRepository.saveAll(noLeidas);
    }

    @Transactional
    public void eliminarNotificacion(String negocioId, String notificacionId) {
        negocioHelper.validarIdNegocio(negocioId);

        var notificacion = notificacionRepository.findById(UUID.fromString(notificacionId))
                .orElseThrow(() -> new NoExisteException(
                        "Notificación no encontrada",
                        "NotificacionService.eliminarNotificacion"
                ));

        notificacionRepository.delete(notificacion);
    }
}
