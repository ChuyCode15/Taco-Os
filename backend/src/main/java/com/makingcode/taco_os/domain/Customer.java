package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "customers")
@Data
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID businessId;

    @Column(nullable = false)
    private String phone;

    private String name;

    private Integer totalPurchases = 0;

    private Integer purchasesTowardReward = 0;

    private Integer rewardsClaimed = 0;

    private Instant createdAt = Instant.now();

    private Instant lastPurchaseAt;
}
