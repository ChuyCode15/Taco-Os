package com.makingcode.taco_os.dto;

import lombok.Data;
import java.time.Instant;
import java.util.List;

@Data
public class SyncResponse {
    private int synced;
    private int failed;
    private List<String> conflicts;
    private Instant serverTime;
}
