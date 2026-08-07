package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.dto.LicenseResponse;
import com.makingcode.taco_os.service.LicenseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class LicenseController {

    private final LicenseService licenseService;

    @GetMapping("/business/{id}/license")
    public ResponseEntity<LicenseResponse> getLicense(@PathVariable UUID id) {
        LicenseResponse resp = licenseService.getLicenseResponse(id);
        if (resp == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/plans")
    public ResponseEntity<List<Map<String, Object>>> getPlans() {
        List<Map<String, Object>> plans = new ArrayList<>();

        Map<String, Object> free = new LinkedHashMap<>();
        free.put("name", "free");
        free.put("price", 0);
        free.put("maxCashiers", 2);
        free.put("maxBusinesses", 1);
        free.put("features", List.of("whatsapp_receipts", "loyalty_program", "basic_reports"));
        plans.add(free);

        Map<String, Object> premium = new LinkedHashMap<>();
        premium.put("name", "premium");
        premium.put("price", 199.0);
        premium.put("currency", "MXN");
        premium.put("interval", "month");
        premium.put("maxCashiers", 5);
        premium.put("maxBusinesses", 2);
        premium.put("features", List.of("whatsapp_receipts", "loyalty_program", "detailed_reports", "ai_insights", "ai_purchase_prediction"));
        plans.add(premium);

        return ResponseEntity.ok(plans);
    }
}
