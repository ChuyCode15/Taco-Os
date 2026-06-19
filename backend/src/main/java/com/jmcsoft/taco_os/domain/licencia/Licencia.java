package com.jmcsoft.taco_os.domain.licencia;

import com.jmcsoft.taco_os.common.enums.EstadoPlan;
import com.jmcsoft.taco_os.common.enums.TipoPlan;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "licenses")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Licencia {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false, unique = true)
    private Negocio negocio;

    @Enumerated(EnumType.STRING)
    @Column(name = "plan", nullable = false)
    private TipoPlan plan = TipoPlan.FREE;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EstadoPlan estado = EstadoPlan.PAGADO;

    @Column(name = "start_date", nullable = false)
    private LocalDate fechaInicio;

    @Column(name = "end_date")
    private LocalDate fechaFin;

    @Column(name = "trial_end_date")
    private LocalDate fechaFinTrial;

    @Column(name = "max_businesses", nullable = false)
    private Integer maxNegocios = 1;

    @Column(name = "max_cashiers", nullable = false)
    private Integer maxCajeros = 2;

    @Column(name = "features", columnDefinition = "TEXT")
    private String features;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        fechaInicio = LocalDate.now();
        registro = LocalDateTime.now();
    }
}
