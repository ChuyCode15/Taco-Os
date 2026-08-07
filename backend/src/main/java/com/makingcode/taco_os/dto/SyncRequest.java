package com.makingcode.taco_os.dto;

import lombok.Data;
import java.util.List;
import java.util.UUID;

@Data
public class SyncRequest {
    private String deviceId;
    private UUID businessId;
    private List<TransactionRequest> transactions;
    private List<ProductSyncItem> products;

    @Data
    public static class ProductSyncItem {
        private String localId;
        private String name;
        private Double price;
        private String category;
    }
}
