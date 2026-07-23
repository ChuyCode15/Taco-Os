package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.superusuario.dto.DatosDetalleAdminTenant;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosLoginSuperSu;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosRespuestaSuperSu;
import com.jmcsoft.taco_os.services.SuperSuService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/super-su")
@RequiredArgsConstructor
@Tag(name = "Super User", description = "SuperUser admin dashboard endpoints")
public class SuperSuController {

    private final SuperSuService superSuService;

    @PostMapping("/login")
    @Operation(summary = "SuperUser login")
    public ResponseEntity<DatosRespuestaSuperSu> login(@RequestBody DatosLoginSuperSu datos) {
        var respuesta = superSuService.login(datos);
        return ResponseEntity.ok(respuesta);
    }

    @GetMapping("/admins")
    @Operation(summary = "List all administrators/tenants")
    public ResponseEntity<List<DatosDetalleAdminTenant>> listarAdmins() {
        return ResponseEntity.ok(superSuService.listarAdmins());
    }

    @GetMapping("/admins/{id}")
    @Operation(summary = "Get administrator detail")
    public ResponseEntity<DatosDetalleAdminTenant> detalleAdmin(@PathVariable String id) {
        return ResponseEntity.ok(superSuService.detalleAdmin(id));
    }

    @PutMapping("/admins/{id}/activar")
    @Operation(summary = "Activate administrator")
    public ResponseEntity<String> activarAdmin(@PathVariable String id) {
        superSuService.activarAdmin(id);
        return ResponseEntity.ok("{\"mensaje\":\"Administrador activado\"}");
    }

    @PutMapping("/admins/{id}/desactivar")
    @Operation(summary = "Deactivate administrator")
    public ResponseEntity<String> desactivarAdmin(@PathVariable String id) {
        superSuService.desactivarAdmin(id);
        return ResponseEntity.ok("{\"mensaje\":\"Administrador desactivado\"}");
    }

    @GetMapping("/stats")
    @Operation(summary = "Dashboard statistics")
    public ResponseEntity<?> estadisticas() {
        return ResponseEntity.ok(superSuService.estadisticas());
    }
}
