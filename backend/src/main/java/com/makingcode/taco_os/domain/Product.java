package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "products")
@Data
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    private Double price;

    private String category;

    @Column(nullable = false)
    private UUID businessId;

    private Boolean isSynced = false;

    private Instant createdAt = Instant.now();
}
