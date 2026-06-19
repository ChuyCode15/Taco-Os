package com.jmcsoft.taco_os.domain.sesioncajero;

import com.jmcsoft.taco_os.common.enums.EstadoSesion;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "cashier_sessions")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CashierSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false)
    private Negocio negocio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cashier_id", nullable = false)
    private Cajero cajero;

    @Column(name = "device_id")
    private String dispositivoId;

    @Column(name = "opening_balance", nullable = false, precision = 10, scale = 2)
    private BigDecimal fondoApertura;

    @Column(name = "closing_balance", precision = 10, scale = 2)
    private BigDecimal fondoCierre;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EstadoSesion estado = EstadoSesion.ABIERTA;

    @Column(name = "opened_at", nullable = false, updatable = false)
    private LocalDateTime apertura;

    @Column(name = "closed_at")
    private LocalDateTime cierre;

    @Column(name = "is_synced", nullable = false)
    private Boolean sincronizado = false;

    @PrePersist
    protected void onCreate() {
        apertura = LocalDateTime.now();
    }
}
