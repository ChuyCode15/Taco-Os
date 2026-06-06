package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "businesses")
@Data
public class Business {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String plan = "free";

    private Double baseCash = 500.0;

    private String currency = "MXN";

    @Column(nullable = false)
    private UUID ownerId;

    private Instant createdAt = Instant.now();
}
