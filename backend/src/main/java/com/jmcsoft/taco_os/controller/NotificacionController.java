package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.notificacion.dto.DatosListaNotificaciones;
import com.jmcsoft.taco_os.services.NotificacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/business/{negocioId}/notifications")
@RequiredArgsConstructor
public class NotificacionController {

    private final NotificacionService notificacionService;

    @GetMapping
    public ResponseEntity<DatosListaNotificaciones> listarNotificaciones(@PathVariable String negocioId) {
        var notificaciones = notificacionService.listarNotificaciones(negocioId);
        return ResponseEntity.ok(notificaciones);
    }

    @PutMapping("/{notificacionId}/read")
    public ResponseEntity<Void> marcarLeida(
            @PathVariable String negocioId,
            @PathVariable String notificacionId) {
        notificacionService.marcarLeida(negocioId, notificacionId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/read-all")
    public ResponseEntity<Void> marcarTodasLeidas(@PathVariable String negocioId) {
        notificacionService.marcarTodasLeidas(negocioId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{notificacionId}")
    public ResponseEntity<Void> eliminarNotificacion(
            @PathVariable String negocioId,
            @PathVariable String notificacionId) {
        notificacionService.eliminarNotificacion(negocioId, notificacionId);
        return ResponseEntity.noContent().build();
    }
}
