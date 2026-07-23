package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.enlace.dto.DatosInvitacion;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosRespuestaEnlace;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosSolicitudEnlace;
import com.jmcsoft.taco_os.domain.enlace.dto.DatosSolicitudInvitacion;
import com.jmcsoft.taco_os.services.EnlaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class EnlaceController {

    private final EnlaceService enlaceService;

    @PostMapping("/business/invitation")
    public ResponseEntity<DatosInvitacion> generarInvitacion(@RequestBody DatosSolicitudInvitacion body) {
        var respuesta = enlaceService.generarInvitacion(body.negocioId(), body.duenoId());
        return ResponseEntity.status(201).body(respuesta);
    }

    @PostMapping("/business/link")
    public ResponseEntity<DatosRespuestaEnlace> enlazarCajero(@RequestBody DatosSolicitudEnlace datos) {
        var respuesta = enlaceService.enlazarCajero(datos);
        return ResponseEntity.ok(respuesta);
    }
}
