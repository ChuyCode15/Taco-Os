package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.helper.CajeroHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.enlace.Invitacion;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosInvitacion;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosRespuestaEnlace;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosSolicitudEnlace;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import com.jmcsoft.taco_os.repository.InvitacionRepository;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EnlaceService {

    private final InvitacionRepository invitacionRepository;
    private final NegocioRepository negocioRepository;
    private final CajeroRepository cajeroRepository;
    private final NegocioHelper negocioHelper;
    private final CajeroHelper cajeroHelper;

    @Transactional
    public DatosInvitacion generarInvitacion(String negocioId, String duenoId) {
        negocioHelper.validarIdNegocio(negocioId);

        var codigo = "INV-" + UUID.randomUUID().toString().substring(0, 8);

        var invitacion = new Invitacion();
        invitacion.setNegocioId(UUID.fromString(negocioId));
        invitacion.setDuenoId(UUID.fromString(duenoId));
        invitacion.setCodigo(codigo);
        invitacion.setExpiraEn(LocalDateTime.now().plusMinutes(15));
        invitacion.setActivo(true);

        invitacionRepository.save(invitacion);

        return new DatosInvitacion(codigo, 15, "tacoos://link?codigo=" + codigo);
    }

    @Transactional
    public DatosRespuestaEnlace enlazarCajero(DatosSolicitudEnlace datos) {
        var invitacion = invitacionRepository.findByCodigoAndActivoTrue(datos.codigo())
                .orElseThrow(() -> new NoExisteException(
                        "El código de invitación no es válido o ya expiró",
                        "EnlaceService.enlazarCajero"
                ));

        if (invitacion.getExpiraEn().isBefore(LocalDateTime.now())) {
            invitacion.setActivo(false);
            invitacionRepository.save(invitacion);

            throw new NoExisteException(
                    "El código de invitación ya expiró",
                    "EnlaceService.enlazarCajero"
            );
        }

        var cajero = cajeroHelper.validarIdCajero(datos.usuarioId());
        var negocio = negocioHelper.validarIdNegocio(invitacion.getNegocioId().toString());

        cajero.setNegocio(negocio);
        cajero.setFechaEnlace(LocalDateTime.now());
        cajeroRepository.save(cajero);

        invitacion.setActivo(false);
        invitacionRepository.save(invitacion);

        return new DatosRespuestaEnlace(
                true,
                negocio.getId().toString(),
                negocio.getNombre(),
                negocio.getDireccion(),
                negocio.getMoneda(),
                negocio.getDineroBase()
        );
    }
}
