package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "licenses")
@Data
public class License {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private UUID businessId;

    @Column(nullable = false)
    private String plan = "free";

    @Enumerated(EnumType.STRING)
    private LicenseStatus status = LicenseStatus.active;

    private LocalDate startDate;

    private LocalDate endDate;

    @Column(nullable = false)
    private Integer maxCashiers = 2;

    @Column(nullable = false)
    private Integer maxBusinesses = 1;

    @Column(columnDefinition = "TEXT")
    private String features = "[\"whatsapp_receipts\",\"loyalty_program\",\"basic_reports\"]";

    public enum LicenseStatus {
        active, expired, trial, suspended
    }
}
