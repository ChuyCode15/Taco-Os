package com.jmcsoft.taco_os.domain.analiticsIA.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public record VentaItemDto(
        int transaction_id,
        String date,
        int cashier_id,
        String product_name,
        String category,
        int quantity,
        double total_price
) { }

