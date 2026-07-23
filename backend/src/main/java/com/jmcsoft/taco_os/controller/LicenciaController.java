package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.licencia.dto.*;
import com.jmcsoft.taco_os.services.LicenciaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class LicenciaController {

    private final LicenciaService licenciaService;

    @GetMapping("/plans")
    public ResponseEntity<DatosListaPlanes> listarPlanes() {
        return ResponseEntity.ok(licenciaService.listarPlanes());
    }

    @GetMapping("/business/{negocioId}/license")
    public ResponseEntity<DatosDetalleLicencia> obtenerLicencia(@PathVariable String negocioId) {
        return ResponseEntity.ok(licenciaService.obtenerLicencia(negocioId));
    }

    @PostMapping("/business/{negocioId}/license/upgrade")
    public ResponseEntity<DatosRespuestaPlan> mejorarPlan(
            @PathVariable String negocioId,
            @RequestBody DatosUpgradePlan datos) {
        return ResponseEntity.ok(licenciaService.mejorarPlan(negocioId, datos));
    }

    @PostMapping("/business/{negocioId}/license/trial")
    public ResponseEntity<DatosRespuestaPlan> activarTrial(
            @PathVariable String negocioId,
            @RequestBody java.util.Map<String, String> body) {
        return ResponseEntity.ok(licenciaService.activarTrial(negocioId, body.get("plan")));
    }
}
