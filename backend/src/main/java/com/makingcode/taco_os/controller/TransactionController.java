package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.dto.SyncRequest;
import com.makingcode.taco_os.dto.SyncResponse;
import com.makingcode.taco_os.dto.TransactionRequest;
import com.makingcode.taco_os.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping("/transactions")
    public ResponseEntity<?> createTransaction(@RequestBody TransactionRequest request) {
        return ResponseEntity.ok(transactionService.createTransaction(request));
    }

    @PostMapping("/transactions/{id}/cancel")
    public ResponseEntity<?> cancelTransaction(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        try {
            UUID cashierId = UUID.fromString(body.get("cashier_id"));
            String reason = body.get("reason");
            String photo = body.get("photo");
            return ResponseEntity.ok(transactionService.cancelTransaction(id, cashierId, reason, photo));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/sync")
    public ResponseEntity<SyncResponse> sync(@RequestBody SyncRequest request) {
        return ResponseEntity.ok(transactionService.syncBatch(request));
    }
}
