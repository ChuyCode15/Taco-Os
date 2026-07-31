package com.makingcode.taco_os.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class LicenseResponse {
    private String plan;
    private String status;
    private LocalDate startDate;
    private LocalDate endDate;
    private Long daysRemaining;
    private Integer maxCashiers;
    private Long currentCashiers;
    private Integer maxBusinesses;
    private Long currentBusinesses;
    private String features;
}
