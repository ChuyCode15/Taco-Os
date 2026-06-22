package com.jmcsoft.taco_os.domain.master.message;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_messages")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "ticket_id", nullable = false)
    private UUID ticketId;

    @Column(name = "sender_id", nullable = false)
    private UUID emisorId;

    @Column(name = "sender_type", nullable = false)
    private String tipoEmisor;

    @Column(name = "content", nullable = false)
    private String contenido;

    @Column(name = "attachment_url")
    private String urlAdjunto;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
