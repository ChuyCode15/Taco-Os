package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.operations.dto.*;
import com.jmcsoft.taco_os.services.master.MasterOperationsService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/master/ops")
@RequiredArgsConstructor
public class MasterOperationsController {

    private final MasterOperationsService operationsService;

    @PostMapping("/force-close-session")
    public ResponseEntity<Void> forzarCierreSesion(
            @RequestBody DatosForzarCierre datos,
            HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        operationsService.forzarCierreSesion(datos, userId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/adjust-balance")
    public ResponseEntity<Void> ajustarSaldo(
            @RequestBody DatosAjustarSaldo datos,
            HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        operationsService.ajustarSaldo(datos, userId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/block-user")
    public ResponseEntity<Void> bloquearUsuario(
            @RequestBody DatosBloquearUsuario datos,
            HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        operationsService.bloquearUsuario(datos, userId);
        return ResponseEntity.ok().build();
    }
}
