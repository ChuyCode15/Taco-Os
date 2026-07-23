package com.jmcsoft.taco_os.domain.enlace;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "invitaciones")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Invitacion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "business_id", nullable = false)
    private UUID negocioId;

    @Column(name = "owner_id", nullable = false)
    private UUID duenoId;

    @Column(name = "code", nullable = false, unique = true)
    private String codigo;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiraEn;

    @Column(name = "is_active", nullable = false)
    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
