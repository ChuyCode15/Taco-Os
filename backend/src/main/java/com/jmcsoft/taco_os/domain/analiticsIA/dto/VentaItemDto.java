package com.jmcsoft.taco_os.domain.analiticsIA.dto;

import java.time.LocalDateTime;

public record VentaItemDto(
        Long invoice_id,
        LocalDateTime timestamp,
        String day_of_week,
        Integer hour,
        String channel,
        String zone,
        String cashier_id,
        String client_name,
        String producto_name,
        Integer quantity,
        Double total_price,
        Boolean is_anulada,
        String insumo_name,
        Double insumo_qty_used,
        String context_event,
        String weather
) {
}
