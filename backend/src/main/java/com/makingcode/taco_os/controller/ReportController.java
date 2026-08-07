package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.domain.Transaction;
import com.makingcode.taco_os.repository.TransactionRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.*;
import java.util.*;

@RestController
@RequestMapping("/api/v1/business/{businessId}/reports")
@RequiredArgsConstructor
public class ReportController {

    private final TransactionRepository transactionRepository;
    private final ObjectMapper objectMapper;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getReport(
            @PathVariable UUID businessId,
            @RequestParam String startDate,
            @RequestParam String endDate) {

        Instant start = LocalDate.parse(startDate).atStartOfDay(ZoneId.systemDefault()).toInstant();
        Instant end = LocalDate.parse(endDate).plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();

        Double totalSales = transactionRepository.sumByBusinessIdAndTypeAndTimestampBetween(
                businessId, Transaction.TransactionType.sale, start, end);
        Double totalExpenses = transactionRepository.sumByBusinessIdAndTypeAndTimestampBetween(
                businessId, Transaction.TransactionType.expense, start, end);
        Double totalDebts = transactionRepository.sumByBusinessIdAndTypeAndTimestampBetween(
                businessId, Transaction.TransactionType.debt, start, end);
        long salesCount = transactionRepository.countByBusinessIdAndTimestampBetweenAndStatus(
                businessId, start, end, Transaction.TransactionStatus.completed);

        if (totalSales == null) totalSales = 0.0;
        if (totalExpenses == null) totalExpenses = 0.0;
        if (totalDebts == null) totalDebts = 0.0;

        // Parse items JSON for top products
        List<String> itemsJsons = transactionRepository.findItemsJsonByBusinessIdAndTimestampBetween(
                businessId, start, end);
        Map<String, Integer> productQty = new LinkedHashMap<>();
        Map<String, Double> productRevenue = new LinkedHashMap<>();
        for (String json : itemsJsons) {
            try {
                List<Map<String, Object>> items = objectMapper.readValue(json, new TypeReference<>() {});
                for (Map<String, Object> item : items) {
                    String name = (String) item.get("name");
                    int qty = ((Number) item.get("qty")).intValue();
                    double price = ((Number) item.get("unit_price")).doubleValue();
                    productQty.merge(name, qty, Integer::sum);
                    productRevenue.merge(name, price * qty, Double::sum);
                }
            } catch (Exception ignored) {}
        }

        List<Map<String, Object>> topProducts = new ArrayList<>();
        productQty.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                .limit(5)
                .forEach(e -> {
                    Map<String, Object> p = new LinkedHashMap<>();
                    p.put("name", e.getKey());
                    p.put("quantity", e.getValue());
                    p.put("revenue", productRevenue.getOrDefault(e.getKey(), 0.0));
                    topProducts.add(p);
                });

        Map<String, Object> cashBalance = new LinkedHashMap<>();
        cashBalance.put("totalSales", totalSales);
        cashBalance.put("totalExpenses", totalExpenses);
        cashBalance.put("totalDebts", totalDebts);
        cashBalance.put("netCash", totalSales - totalExpenses);
        cashBalance.put("cashInRegister", (totalSales - totalExpenses) * 0.3);
        cashBalance.put("baseCash", 500.0);
        cashBalance.put("withdrawable", Math.max(0, (totalSales - totalExpenses) * 0.3 - 500));

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("period", startDate + " to " + endDate);
        response.put("cashBalance", cashBalance);
        response.put("salesCount", salesCount);
        response.put("topProducts", topProducts);

        return ResponseEntity.ok(response);
    }
}
