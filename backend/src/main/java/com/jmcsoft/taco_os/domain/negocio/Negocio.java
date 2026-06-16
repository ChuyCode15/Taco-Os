package com.jmcsoft.taco_os.domain.negocio;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "negocios")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Negocio {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "name", nullable = false)
    private String nombre;

    @Column(name = "location", nullable = false)
    private String ubicacion;

    @Column(name = "closing_time")
    private String horaCierre;

    @Column(name = "currency", nullable = false)
    private String moneda = "MXN";

    @Column(name = "base_cash", nullable = false)
    private BigDecimal dineroBase = BigDecimal.valueOf(500);

    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
