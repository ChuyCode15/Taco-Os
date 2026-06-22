package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.master.auditlog.MasterAuditLog;
import com.jmcsoft.taco_os.domain.master.operations.dto.*;
import com.jmcsoft.taco_os.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MasterOperationsService {

    private final CajeroRepository cajeroRepository;
    private final NegocioRepository negocioRepository;
    private final MasterAuditLogRepository auditLogRepository;

    @Transactional
    public void forzarCierreSesion(DatosForzarCierre datos, String userId) {
        var cajero = cajeroRepository.findById(UUID.fromString(datos.cajeroId()))
                .orElseThrow(() -> new NoExisteException("Cajero no encontrado", "MasterOperationsService.forzarCierreSesion"));

        var audit = new MasterAuditLog();
        audit.setUsuarioId(UUID.fromString(userId));
        audit.setAccion("FORCE_CLOSE_SESSION");
        audit.setTipoObjetivo("CAJERO");
        audit.setObjetivoId(cajero.getId());
        audit.setDetalles("Forzar cierre de sesión. Razón: " + datos.razon());
        auditLogRepository.save(audit);
    }

    @Transactional
    public void ajustarSaldo(DatosAjustarSaldo datos, String userId) {
        var negocio = negocioRepository.findById(UUID.fromString(datos.negocioId()))
                .orElseThrow(() -> new NoExisteException("Negocio no encontrado", "MasterOperationsService.ajustarSaldo"));

        var audit = new MasterAuditLog();
        audit.setUsuarioId(UUID.fromString(userId));
        audit.setAccion("ADJUST_BALANCE");
        audit.setTipoObjetivo("NEGOCIO");
        audit.setObjetivoId(negocio.getId());
        audit.setDetalles("Saldo ajustado a " + datos.nuevoDineroBase() + ". Razón: " + datos.razon());
        auditLogRepository.save(audit);
    }

    @Transactional
    public void bloquearUsuario(DatosBloquearUsuario datos, String userId) {
        var audit = new MasterAuditLog();
        audit.setUsuarioId(UUID.fromString(userId));
        audit.setAccion(datos.bloquear() ? "BLOCK_USER" : "UNBLOCK_USER");
        audit.setTipoObjetivo("CLIENT");
        audit.setObjetivoId(UUID.fromString(datos.clienteId()));
        audit.setDetalles((datos.bloquear() ? "Bloqueado" : "Desbloqueado") + ". Razón: " + datos.razon());
        auditLogRepository.save(audit);
    }
}
