package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosAperturaSesion;
import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosDetalleSesion;
import com.jmcsoft.taco_os.services.CashierSessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/api/v1/cashier")
@RequiredArgsConstructor
public class CashierSessionController {

    private final CashierSessionService sesionService;

    @PostMapping("/open-session")
    public ResponseEntity<DatosDetalleSesion> abrirSesion(
            @RequestBody DatosAperturaSesion datos,
            UriComponentsBuilder ucb) {
        var sesion = sesionService.abrirSesion(datos);
        var uri = ucb.path("/api/v1/cashier/session/{id}").buildAndExpand(sesion.id()).toUri();
        return ResponseEntity.created(uri).body(sesion);
    }
}
