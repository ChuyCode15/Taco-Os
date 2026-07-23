package com.jmcsoft.taco_os.domain.master.auditlog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_audit_log")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID usuarioId;

    @Column(name = "action", nullable = false)
    private String accion;

    @Column(name = "target_type")
    private String tipoObjetivo;

    @Column(name = "target_id")
    private UUID objetivoId;

    @Column(name = "details")
    private String detalles;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
