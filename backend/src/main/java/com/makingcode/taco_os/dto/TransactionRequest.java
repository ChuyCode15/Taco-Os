package com.makingcode.taco_os.dto;

import lombok.Data;
import java.time.Instant;
import java.util.UUID;

@Data
public class TransactionRequest {
    private UUID businessId;
    private String type;
    private UUID cashierId;
    private String deviceId;
    private String customerPhone;
    private String itemsJson;
    private String paymentJson;
    private Double total;
    private String ticketFolio;
    private String category;
    private String creditor;
    private String dueDate;
    private Instant timestamp;
    private Boolean isSynced = false;
}
