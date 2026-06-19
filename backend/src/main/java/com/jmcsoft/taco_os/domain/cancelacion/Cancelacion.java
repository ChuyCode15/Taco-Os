package com.jmcsoft.taco_os.domain.cancelacion;

import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.transaccion.Transaccion;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "cancellations")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cancelacion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id", nullable = false)
    private Transaccion transaccion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cashier_id", nullable = false)
    private Cajero cajero;

    @Column(name = "reason", nullable = false)
    private String motivo;

    @Column(name = "photo_url", nullable = false, columnDefinition = "TEXT")
    private String fotoUrl;

    @Column(name = "cancelled_at", nullable = false, updatable = false)
    private LocalDateTime canceladoEn;

    @PrePersist
    protected void onCreate() {
        canceladoEn = LocalDateTime.now();
    }
}
