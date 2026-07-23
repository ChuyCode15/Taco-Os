package com.jmcsoft.taco_os.domain.transaccion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Request to register a transaction")
public record DatosRegistroTransaccion(
        @JsonProperty("business_id") @Schema(description = "Business identifier", example = "business-123") String negocioId,
        @JsonProperty("session_id") @Schema(description = "Cashier session identifier", example = "session-456") String sesionId,
        @JsonProperty("type") @Schema(description = "Transaction type", example = "sale") String tipo,
        @JsonProperty("cashier_id") @Schema(description = "Cashier identifier", example = "cashier-789") String cajeroId,
        @JsonProperty("device_id") @Schema(description = "Device identifier", example = "device-001") String dispositivoId,
        @JsonProperty("items") @Schema(description = "Items as JSON string", example = "[{\"name\":\"Taco\",\"qty\":2}]") String itemsJson,
        @JsonProperty("payment") @Schema(description = "Payment details") DatosPago pago,
        @JsonProperty("total") @Schema(description = "Transaction total amount", example = "150.00") BigDecimal total,
        @JsonProperty("description") @Schema(description = "Transaction description", example = "Lunch order") String descripcion
) {}
