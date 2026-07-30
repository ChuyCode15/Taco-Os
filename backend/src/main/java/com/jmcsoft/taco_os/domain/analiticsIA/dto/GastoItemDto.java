package com.jmcsoft.taco_os.domain.analiticsIA.dto;

import java.time.LocalDateTime;

public record GastoItemDto(
        LocalDateTime timesstamp,
        String category,
        Double amount
) {
}
