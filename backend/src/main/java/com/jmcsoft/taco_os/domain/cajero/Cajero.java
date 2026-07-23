package com.jmcsoft.taco_os.domain.cajero;

import com.jmcsoft.taco_os.domain.negocio.Negocio;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "cajeros")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cajero {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "google_id", nullable = false, unique = true)
    private String idGoogle;

    @Column(name = "full_name", nullable = false)
    private String nombreCompleto;

    @Column(name = "nickname")
    private String nickname;

    @Column(name = "email", nullable = false)
    private String correo;

    @Column(name = "phone")
    private String numero;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id")
    private Negocio negocio;

    @Column(name = "permissions", columnDefinition = "TEXT")
    private String permisos;

    @Column(name = "linked_at")
    private LocalDateTime fechaEnlace;

    @Column(name = "is_active", nullable = false)
    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        registro = LocalDateTime.now();
    }
}
