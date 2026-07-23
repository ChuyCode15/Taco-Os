package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.client.dto.*;
import com.jmcsoft.taco_os.services.master.MasterClientService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/master/clients")
@RequiredArgsConstructor
public class MasterClientController {

    private final MasterClientService clientService;

    @GetMapping
    public ResponseEntity<List<DatosClienteLista>> listarClientes() {
        return ResponseEntity.ok(clientService.listarClientes());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DatosDetalleCliente> obtenerDetalle(@PathVariable String id) {
        return ResponseEntity.ok(clientService.obtenerDetalle(id));
    }

    @PutMapping("/{id}/toggle")
    public ResponseEntity<Void> toggleActivo(@PathVariable String id) {
        clientService.toggleActivo(id);
        return ResponseEntity.ok().build();
    }
}
