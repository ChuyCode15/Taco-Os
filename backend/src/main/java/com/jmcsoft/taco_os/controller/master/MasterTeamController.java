package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.team.dto.*;
import com.jmcsoft.taco_os.services.master.MasterTeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/master/team")
@RequiredArgsConstructor
public class MasterTeamController {

    private final MasterTeamService teamService;

    @GetMapping
    public ResponseEntity<List<DatosMiembroEquipo>> listarMiembros() {
        return ResponseEntity.ok(teamService.listarMiembros());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DatosMiembroEquipo> obtenerMiembro(@PathVariable String id) {
        return ResponseEntity.ok(teamService.obtenerMiembro(id));
    }

    @PostMapping
    public ResponseEntity<DatosMiembroEquipo> crearMiembro(@RequestBody DatosCrearMiembro datos) {
        return ResponseEntity.status(201).body(teamService.crearMiembro(datos));
    }

    @PutMapping("/{id}/toggle")
    public ResponseEntity<Void> toggleActivo(@PathVariable String id) {
        teamService.toggleActivo(id);
        return ResponseEntity.ok().build();
    }
}
