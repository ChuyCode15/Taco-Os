package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.transaccion.dto.DatosCancelacion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRegistroTransaccion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaCancelacion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRespuestaTransaccion;
import com.jmcsoft.taco_os.services.TransaccionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class TransaccionController {

    private final TransaccionService transaccionService;

    @PostMapping("/transactions")
    public ResponseEntity<DatosRespuestaTransaccion> registrarTransaccion(@RequestBody DatosRegistroTransaccion datos) {
        var transaccion = transaccionService.registrarTransaccion(datos);
        return ResponseEntity.status(201).body(transaccion);
    }

    @PostMapping("/transactions/{id}/cancel")
    public ResponseEntity<DatosRespuestaCancelacion> cancelarTransaccion(
            @PathVariable String id,
            @RequestBody DatosCancelacion datos) {
        var resultado = transaccionService.cancelarTransaccion(id, datos);
        return ResponseEntity.ok(resultado);
    }
}
