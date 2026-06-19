package com.jmcsoft.taco_os.domain.producto;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "productos")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Producto {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "name", nullable = false)
    private String nombre;

    @Column(name = "price", nullable = false)
    private BigDecimal precio;

    @Column(name = "category", nullable = false)
    @Enumerated(EnumType.STRING)
    private Categoria categoria;

    @Column(name = "photo_url")
    private String fotoUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false)
    private Negocio negocio;

    @Column(name = "is_active", nullable = false)
    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        registro = LocalDateTime.now();
    }
}
