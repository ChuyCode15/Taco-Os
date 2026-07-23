package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.services.SyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class SyncController {

    private final SyncService syncService;

    @PostMapping("/sync")
    public ResponseEntity<Map<String, Object>> sincronizar(@RequestBody Map<String, Object> payload) {
        var resultado = syncService.sincronizarBatch(payload);
        return ResponseEntity.ok(resultado);
    }
}
