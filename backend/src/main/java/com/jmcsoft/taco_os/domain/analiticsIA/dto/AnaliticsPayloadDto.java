package com.jmcsoft.taco_os.domain.analiticsIA.dto;

import java.util.List;

public record AnaliticsPayloadDto(
        List<VentaItemDto> ventas,
        List<GastoItemDto> gastos
) {
}
