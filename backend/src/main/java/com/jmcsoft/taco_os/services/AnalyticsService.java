package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnaliticsPayloadDto;
import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnalyticsReportDto;
import com.jmcsoft.taco_os.domain.analiticsIA.dto.VentaItemDto;
import com.jmcsoft.taco_os.services.TacosIAClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@Slf4j
public class AnalyticsService {

    private final VentaRepository ventaRepository;
    private final TacosIAClient tacosIAClient;

    public AnalyticsService(VentaRepository ventaRepository, TacosIAClient tacosIAClient) {
        this.ventaRepository = ventaRepository;
        this.tacosIAClient = tacosIAClient;
    }

    public AnalyticsReportDto generarReporteParaNegocio(String negocioId) {
        // 1. Obtener ventas del día actual
        LocalDateTime inicio = LocalDate.now().atStartOfDay();
        LocalDateTime fin = LocalDateTime.now();

        List<VentaItemDto> ventas = ventaRepository.findVentasByNegocioId(negocioId, inicio, fin)
                .stream()
                .map(v -> new VentaItemDto(
                        v.getId(),
                        v.getFecha().toString(),
                        v.getCajeroId(),
                        v.getProductoNombre(),
                        v.getCategoria(),
                        v.getCantidad(),
                        v.getTotal()
                ))
                .toList();

        if (ventas.isEmpty()) {
            return new AnalyticsReportDto("empty", null, "Aún no hay suficientes ventas hoy para generar un análisis.");
        }

        // 2. Enviar a FastAPI
        AnaliticsPayloadDto payload = new AnaliticsPayloadDto(ventas);
        return tacosIAClient.obtenerReporteIA(payload);
    }
}