package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.corte.dto.DatosCierreSesion;
import com.jmcsoft.taco_os.domain.corte.dto.DatosRespuestaCorte;
import com.jmcsoft.taco_os.services.DailyCutService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/cashier")
@RequiredArgsConstructor
public class DailyCutController {

    private final DailyCutService corteService;

    @PostMapping("/close-session")
    public ResponseEntity<DatosRespuestaCorte> cerrarSesion(@RequestBody DatosCierreSesion datos) {
        var corte = corteService.cerrarSesion(datos);
        return ResponseEntity.ok(corte);
    }
}
