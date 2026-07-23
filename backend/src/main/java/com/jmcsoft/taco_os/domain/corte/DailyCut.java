package com.jmcsoft.taco_os.domain.corte;

import com.jmcsoft.taco_os.common.enums.EstadoCorte;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "daily_cuts")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyCut {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private CashierSession sesion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false)
    private Negocio negocio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cashier_id", nullable = false)
    private Cajero cajero;

    @Column(name = "total_sales", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalVentas;

    @Column(name = "total_expenses", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalGastos;

    @Column(name = "cash_sales", nullable = false, precision = 10, scale = 2)
    private BigDecimal ventasEfectivo;

    @Column(name = "card_sales", nullable = false, precision = 10, scale = 2)
    private BigDecimal ventasTarjeta;

    @Column(name = "opening_balance", nullable = false, precision = 10, scale = 2)
    private BigDecimal fondoApertura;

    @Column(name = "expected_cash", nullable = false, precision = 10, scale = 2)
    private BigDecimal efectivoEsperado;

    @Column(name = "actual_cash", precision = 10, scale = 2)
    private BigDecimal efectivoReal;

    @Column(name = "difference", precision = 10, scale = 2)
    private BigDecimal diferencia;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EstadoCorte estado;

    @Column(name = "notes")
    private String notas;

    @Column(name = "ticket_url")
    private String ticketUrl;

    @Column(name = "opened_at", nullable = false)
    private LocalDateTime apertura;

    @Column(name = "closed_at", nullable = false)
    private LocalDateTime cierre;

    @Column(name = "is_synced", nullable = false)
    private Boolean sincronizado = false;

    @PrePersist
    protected void onCreate() {
        cierre = LocalDateTime.now();
    }
}
