package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoSesion;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.YaExisteException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosAperturaSesion;
import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosDetalleSesion;
import com.jmcsoft.taco_os.domain.sesioncajero.mapper.CashierSessionMapper;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CashierSessionService {

    private final CashierSessionRepository sesionRepository;
    private final NegocioHelper negocioHelper;
    private final CajeroHelper cajeroHelper;
    private final CashierSessionMapper sesionMapper;

    @Transactional
    public DatosDetalleSesion abrirSesion(DatosAperturaSesion datos) {
        var negocio = negocioHelper.validarIdNegocio(datos.businessId());
        var cajero = cajeroHelper.validarIdCajero(datos.cashierId());

        var sesionAbierta = sesionRepository
                .findByNegocioIdAndCajeroIdAndEstado(negocio.getId(), cajero.getId(), EstadoSesion.ABIERTA);
        if (sesionAbierta.isPresent()) {
            throw new YaExisteException(
                    "El cajero ya tiene una sesión abierta",
                    "CashierSessionService.abrirSesion"
            );
        }

        var sesion = new CashierSession();
        sesion.setNegocio(negocio);
        sesion.setCajero(cajero);
        sesion.setDispositivoId(datos.deviceId());
        sesion.setFondoApertura(datos.fondoApertura());
        sesion.setEstado(EstadoSesion.ABIERTA);

        var guardada = sesionRepository.save(sesion);
        return sesionMapper.sesionADetalle(guardada);
    }

    @Transactional(readOnly = true)
    public CashierSession obtenerSesionAbierta(String negocioId, String cajeroId) {
        return sesionRepository
                .findByNegocioIdAndCajeroIdAndEstado(
                        UUID.fromString(negocioId),
                        UUID.fromString(cajeroId),
                        EstadoSesion.ABIERTA)
                .orElseThrow(() -> new NoExisteException(
                        "No hay sesión abierta para este cajero",
                        "CashierSessionService.obtenerSesionAbierta"
                ));
    }
}
