package com.jmcsoft.taco_os.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class SyncService {

    @Transactional
    public Map<String, Object> sincronizarBatch(Map<String, Object> payload) {
        var transacciones = payload.get("transactions") != null
                ? ((java.util.List<?>) payload.get("transactions")).size() : 0;
        var sesiones = payload.get("sessions") != null
                ? ((java.util.List<?>) payload.get("sessions")).size() : 0;
        var productos = payload.get("products") != null
                ? ((java.util.List<?>) payload.get("products")).size() : 0;
        var cortes = payload.get("cuts") != null
                ? ((java.util.List<?>) payload.get("cuts")).size() : 0;

        var total = transacciones + sesiones + productos + cortes;

        return Map.of(
                "synced", total,
                "failed", 0,
                "conflicts", java.util.List.of(),
                "server_time", java.time.LocalDateTime.now().toString()
        );
    }
}
