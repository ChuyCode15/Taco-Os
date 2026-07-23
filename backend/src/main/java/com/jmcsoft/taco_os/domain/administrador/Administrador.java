package com.jmcsoft.taco_os.domain.administrador;

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

@Table(name = "administradores")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Administrador {

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

    @Enumerated(EnumType.STRING)
    @Column(name = "plan_type", nullable = false)
    private TipoPlan tipoPlan = TipoPlan.FREE;

    @Enumerated(EnumType.STRING)
    @Column(name = "plan_status", nullable = false)
    private EstadoPlan estadoPlan;

    @Column(name = "due_date")
    private LocalDate fechaVencimiento;

    @Column(name = "is_active", nullable = false)
    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        registro = LocalDateTime.now();
    }
}
