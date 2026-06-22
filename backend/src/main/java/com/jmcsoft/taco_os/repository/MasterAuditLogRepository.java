package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.auditlog.MasterAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MasterAuditLogRepository extends JpaRepository<MasterAuditLog, UUID> {
    List<MasterAuditLog> findByUsuarioIdOrderByCreadoElDesc(UUID usuarioId);
    List<MasterAuditLog> findTop20ByOrderByCreadoElDesc();
}
