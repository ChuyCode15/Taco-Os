package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import com.jmcsoft.taco_os.services.NegocioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/business")
@RequiredArgsConstructor
public class negociosController {

    private final NegocioService negocioService;

    public ResponseEntity<DatosDetalleNegocio> registrarNegocio(@RequestBody DatosRegistroNegocio datos, UriComponentsBuilder ucb) {
        var negocio = negocioService.registrarNegocio(datos);
        var uri = ucb.path("/business/{id}").buildAndExpand(negocio).toUri();
        return ResponseEntity.created(uri).body(negocio);
    }


}
