package com.jmcsoft.taco_os.domain.master.ticket;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_tickets")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterTicket {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "client_id", nullable = false)
    private UUID clienteId;

    @Column(name = "title", nullable = false)
    private String titulo;

    @Column(name = "description")
    private String descripcion;

    @Column(name = "priority", nullable = false)
    private String prioridad;

    @Column(name = "status", nullable = false)
    private String estado;

    @Column(name = "assigned_to")
    private UUID asignadoA;

    @Column(name = "created_by", nullable = false)
    private UUID creadoPor;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime actualizadoEl;

    @Column(name = "resolved_at")
    private LocalDateTime resueltoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
        actualizadoEl = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        actualizadoEl = LocalDateTime.now();
    }
}
