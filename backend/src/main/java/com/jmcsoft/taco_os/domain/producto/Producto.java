package com.jmcsoft.taco_os.domain.producto;

import com.jmcsoft.taco_os.common.enums.Categoria;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.Id;

import java.math.BigDecimal;
import java.util.UUID;

@Table(name = "productos")
@Entity

@NoArgsConstructor
@AllArgsConstructor
@Data

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
    private String miniVistaUrl;

    private Boolean activo = true;

}
