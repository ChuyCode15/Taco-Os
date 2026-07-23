package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosListaCajeros;
import com.jmcsoft.taco_os.services.NegocioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/api/v1/business")
@RequiredArgsConstructor
public class negociosController {

    private final NegocioService negocioService;

    @PostMapping
    public ResponseEntity<DatosDetalleNegocio> registrarNegocio(@RequestBody DatosRegistroNegocio datos,
                                                                  @RequestParam String duenoId,
                                                                  UriComponentsBuilder ucb) {
        var negocio = negocioService.registrarNegocio(datos, duenoId);
        var uri = ucb.path("/api/v1/business/{id}").buildAndExpand(negocio.id()).toUri();
        return ResponseEntity.created(uri).body(negocio);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DatosDetalleNegocio> obtenerDetalle(@PathVariable String id) {
        var negocio = negocioService.obtenerDetalle(id);
        return ResponseEntity.ok(negocio);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DatosDetalleNegocio> editarNegocio(@PathVariable String id,
                                                              @RequestBody DatosRegistroNegocio datos) {
        var negocio = negocioService.editarNegocio(id, datos);
        return ResponseEntity.ok(negocio);
    }

    @GetMapping("/{id}/cajeros")
    public ResponseEntity<DatosListaCajeros> listarCajeros(@PathVariable String id) {
        var cajeros = negocioService.listarCajeros(id);
        return ResponseEntity.ok(cajeros);
    }
}
