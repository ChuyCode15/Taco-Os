package com.jmcsoft.taco_os.domain.transaccion.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Payment details")
public record DatosPago(
        @JsonProperty("method") @Schema(description = "Payment method", example = "cash") String metodo,
        @JsonProperty("amount_received") @Schema(description = "Amount received from customer", example = "200.00") BigDecimal montoRecibido,
        @JsonProperty("change") @Schema(description = "Change given to customer", example = "50.00") BigDecimal cambio,
        @JsonProperty("card_photo_url") @Schema(description = "Receipt or card photo URL", example = "https://example.com/receipt.jpg") String fotoBaucher
) {}
