package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.dashboard.dto.DatosEstadisticas;
import com.jmcsoft.taco_os.services.master.MasterDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/master/dashboard")
@RequiredArgsConstructor
public class MasterDashboardController {

    private final MasterDashboardService dashboardService;

    @GetMapping("/stats")
    public ResponseEntity<DatosEstadisticas> obtenerEstadisticas() {
        return ResponseEntity.ok(dashboardService.obtenerEstadisticas());
    }
}
