package com.jmcsoft.taco_os.domain.corte.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Daily cut response")
public record DatosRespuestaCorte(
        @JsonProperty("cut_id") @Schema(description = "Daily cut identifier", example = "cut-001") String corteId,
        @JsonProperty("session_id") @Schema(description = "Cashier session identifier", example = "session-456") String sesionId,
        @JsonProperty("opened_at") @Schema(description = "Session opening timestamp", example = "2026-06-18T08:00:00Z") String apertura,
        @JsonProperty("closed_at") @Schema(description = "Session closing timestamp", example = "2026-06-18T18:00:00Z") String cierre,
        @Schema(description = "Financial summary of the daily cut") DatosResumen resumen,
        @JsonProperty("status") @Schema(description = "Cut status", example = "completed") String estado,
        @JsonProperty("ticket_url") @Schema(description = "URL to download the cut ticket", example = "https://example.com/ticket/cut-001.pdf") String ticketUrl
) {}
