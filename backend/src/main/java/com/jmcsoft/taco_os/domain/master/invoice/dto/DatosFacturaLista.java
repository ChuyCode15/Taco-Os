package com.jmcsoft.taco_os.domain.master.invoice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "Invoice list item")
public record DatosFacturaLista(
        @Schema(description = "Invoice ID")
        String id,
        @Schema(description = "Client name")
        String clienteNombre,
        @Schema(description = "Amount")
        BigDecimal monto,
        @Schema(description = "Plan")
        String plan,
        @Schema(description = "Status: PENDIENTE, PAGADA, VENCIDA")
        String estado,
        @Schema(description = "Due date")
        String fechaVencimiento,
        @Schema(description = "Paid at")
        String pagadoEl
) {}
