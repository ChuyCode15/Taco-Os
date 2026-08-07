package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "cancellations")
@Data
public class Cancellation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID transactionId;

    @Column(nullable = false)
    private UUID businessId;

    private UUID cashierId;

    @Column(nullable = false)
    private String reason;

    @Column(columnDefinition = "TEXT")
    private String photoUrl;

    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    private Boolean ownerNotified = false;
}
