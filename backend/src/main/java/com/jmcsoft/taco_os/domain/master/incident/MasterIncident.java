package com.jmcsoft.taco_os.domain.master.incident;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_incidents")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterIncident {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "client_id")
    private UUID clienteId;

    @Column(name = "title", nullable = false)
    private String titulo;

    @Column(name = "description")
    private String descripcion;

    @Column(name = "severity", nullable = false)
    private String severidad;

    @Column(name = "status", nullable = false)
    private String estado;

    @Column(name = "detected_by")
    private UUID detectadoPor;

    @Column(name = "assigned_to")
    private UUID asignadoA;

    @Column(name = "action_taken")
    private String accionTomada;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @Column(name = "resolved_at")
    private LocalDateTime resueltoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
