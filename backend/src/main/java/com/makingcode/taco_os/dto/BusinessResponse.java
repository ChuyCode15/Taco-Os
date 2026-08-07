package com.makingcode.taco_os.dto;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class BusinessResponse {
    private UUID id;
    private String name;
    private String plan;
    private Double baseCash;
    private String currency;
    private Long cashiersCount;
    private Integer maxCashiers;
    private Integer maxBusinesses;
    private Instant createdAt;
}
