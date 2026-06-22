package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.invoice.dto.*;
import com.jmcsoft.taco_os.services.master.MasterBillingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/master/billing")
@RequiredArgsConstructor
public class MasterBillingController {

    private final MasterBillingService billingService;

    @GetMapping("/summary")
    public ResponseEntity<DatosResumenFacturacion> obtenerResumen() {
        return ResponseEntity.ok(billingService.obtenerResumen());
    }

    @GetMapping("/invoices")
    public ResponseEntity<List<DatosFacturaLista>> listarFacturas() {
        return ResponseEntity.ok(billingService.listarFacturas());
    }
}
