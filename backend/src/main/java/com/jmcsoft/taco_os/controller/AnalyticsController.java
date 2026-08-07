package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnaliticsPayloadDto;
import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnalyticsReportDto;
import com.jmcsoft.taco_os.services.TacosIAClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

    private final TacosIAClient tacosIAClient;

    public AnalyticsController(TacosIAClient tacosIAClient) {
        this.tacosIAClient = tacosIAClient;
    }

    @PostMapping("/report")
    public ResponseEntity<?> generarReporte(@RequestBody AnaliticsPayloadDto payload) {
        log.info("Payload recibido: {}", payload);
        try {
            AnalyticsReportDto reporte = tacosIAClient.obtenerReporteIA(payload);
            log.info("Reporte recibido de FastAPI: {}", reporte);
            return ResponseEntity.ok(reporte);
        } catch (Exception e) {
            log.error("Error al generar reporte IA", e);
            return ResponseEntity.status(502).body(
                    new ErrorResponse("Error al generar reporte IA", e.getMessage())
            );
        }
    }


    // DTO simple para errores
    public record ErrorResponse(String message, String details) {}
}


