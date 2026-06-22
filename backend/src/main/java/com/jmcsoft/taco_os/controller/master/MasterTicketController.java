package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.ticket.dto.*;
import com.jmcsoft.taco_os.domain.master.message.dto.*;
import com.jmcsoft.taco_os.services.master.MasterTicketService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/master/tickets")
@RequiredArgsConstructor
public class MasterTicketController {

    private final MasterTicketService ticketService;

    @GetMapping
    public ResponseEntity<List<DatosDetalleTicket>> listarTickets() {
        return ResponseEntity.ok(ticketService.listarTickets());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DatosDetalleTicket> obtenerDetalle(@PathVariable String id) {
        return ResponseEntity.ok(ticketService.obtenerDetalle(id));
    }

    @PostMapping
    public ResponseEntity<DatosDetalleTicket> crearTicket(
            @RequestBody DatosCrearTicket datos,
            HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        return ResponseEntity.status(201).body(ticketService.crearTicket(datos, userId));
    }

    @PutMapping("/{id}/assign")
    public ResponseEntity<Void> asignarTicket(
            @PathVariable String id,
            @RequestBody DatosAsignarTicket datos) {
        ticketService.asignarTicket(id, datos);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Void> cambiarEstado(
            @PathVariable String id,
            @RequestParam String status) {
        ticketService.cambiarEstado(id, status);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/messages")
    public ResponseEntity<List<DatosMensajeRespuesta>> listarMensajes(@PathVariable String id) {
        return ResponseEntity.ok(ticketService.listarMensajes(id));
    }

    @PostMapping("/{id}/messages")
    public ResponseEntity<DatosMensajeRespuesta> enviarMensaje(
            @PathVariable String id,
            @RequestBody DatosEnviarMensaje datos,
            HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        return ResponseEntity.status(201).body(ticketService.enviarMensaje(id, datos, userId, "STAFF"));
    }
}
