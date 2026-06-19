package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.services.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/business/{negocioId}/reports")
@RequiredArgsConstructor
public class ReporteController {

    private final ReporteService reporteService;

    @GetMapping("/open-sessions")
    public ResponseEntity<List<Map<String, Object>>> cajasAbiertas(@PathVariable String negocioId) {
        return ResponseEntity.ok(reporteService.cajasAbiertas(negocioId));
    }

    @GetMapping("/cuts")
    public ResponseEntity<List<Map<String, Object>>> listaCortes(@PathVariable String negocioId) {
        return ResponseEntity.ok(reporteService.listaCortes(negocioId));
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> estadisticas(@PathVariable String negocioId) {
        return ResponseEntity.ok(Map.of(
                "current_week", Map.of(
                        "total_sales", java.math.BigDecimal.ZERO,
                        "total_expenses", java.math.BigDecimal.ZERO,
                        "transaction_count", 0,
                        "avg_ticket", java.math.BigDecimal.ZERO
                ),
                "best_week", Map.of(
                        "week_of", "2026-06-01",
                        "total_sales", java.math.BigDecimal.ZERO,
                        "total_expenses", java.math.BigDecimal.ZERO,
                        "transaction_count", 0,
                        "avg_ticket", java.math.BigDecimal.ZERO
                ),
                "comparison", Map.of(
                        "sales_vs_best", 0.0,
                        "transactions_vs_best", 0.0
                )
        ));
    }
}
