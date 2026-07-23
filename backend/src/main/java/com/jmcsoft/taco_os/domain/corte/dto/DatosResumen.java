package com.jmcsoft.taco_os.domain.corte.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Daily cut financial summary")
public record DatosResumen(
        @JsonProperty("total_sales") @Schema(description = "Total sales amount", example = "5000.00") BigDecimal totalVentas,
        @JsonProperty("total_expenses") @Schema(description = "Total expenses amount", example = "800.00") BigDecimal totalGastos,
        @JsonProperty("cash_sales") @Schema(description = "Cash sales amount", example = "3500.00") BigDecimal ventasEfectivo,
        @JsonProperty("card_sales") @Schema(description = "Card sales amount", example = "1500.00") BigDecimal ventasTarjeta,
        @JsonProperty("opening_balance") @Schema(description = "Opening cash balance", example = "1000.00") BigDecimal fondoApertura,
        @JsonProperty("expected_cash") @Schema(description = "Expected cash in drawer", example = "3700.00") BigDecimal efectivoEsperado,
        @JsonProperty("actual_cash") @Schema(description = "Actual cash in drawer", example = "3650.00") BigDecimal efectivoReal,
        @JsonProperty("difference") @Schema(description = "Difference between expected and actual cash", example = "-50.00") BigDecimal diferencia
) {}
