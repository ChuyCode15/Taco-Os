package com.jmcsoft.taco_os.domain.master.invoice;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_invoices")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterInvoice {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "client_id", nullable = false)
    private UUID clienteId;

    @Column(name = "amount", nullable = false)
    private BigDecimal monto;

    @Column(name = "plan", nullable = false)
    private String plan;

    @Column(name = "status", nullable = false)
    private String estado;

    @Column(name = "due_date", nullable = false)
    private LocalDate fechaVencimiento;

    @Column(name = "paid_at")
    private LocalDateTime pagadoEl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime creadoEl;

    @PrePersist
    protected void onCreate() {
        creadoEl = LocalDateTime.now();
    }
}
