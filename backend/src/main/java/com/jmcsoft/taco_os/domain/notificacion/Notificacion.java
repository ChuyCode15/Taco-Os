package com.jmcsoft.taco_os.domain.notificacion;

import com.jmcsoft.taco_os.common.enums.TipoNotificacion;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "notifications")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notificacion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false)
    private Negocio negocio;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private TipoNotificacion tipo;

    @Column(name = "message", nullable = false)
    private String mensaje;

    @Column(name = "data_json", columnDefinition = "TEXT")
    private String datosJson;

    @Column(name = "is_read", nullable = false)
    private Boolean leido = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        registro = LocalDateTime.now();
    }
}
