package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "transactions")
@Data
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID businessId;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private UUID cashierId;

    private String deviceId;

    private String customerPhone;

    @Column(columnDefinition = "TEXT")
    private String itemsJson;

    private Double total;

    @Column(columnDefinition = "TEXT")
    private String paymentJson;

    private String ticketFolio;

    @Enumerated(EnumType.STRING)
    private TransactionStatus status = TransactionStatus.completed;

    @Column(nullable = false)
    private Instant timestamp;

    @Column(nullable = false)
    private Boolean isSynced = false;

    private String category;

    private String creditor;

    private LocalDate dueDate;

    @PrePersist
    void onCreate() {
        if (this.timestamp == null) this.timestamp = Instant.now();
    }

    public enum TransactionType {
        sale, expense, debt
    }

    public enum TransactionStatus {
        completed, cancelled
    }
}
