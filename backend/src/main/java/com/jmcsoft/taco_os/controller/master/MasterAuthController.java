package com.jmcsoft.taco_os.controller.master;

import com.jmcsoft.taco_os.domain.master.user.dto.*;
import com.jmcsoft.taco_os.services.master.MasterAuthService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/master/auth")
@RequiredArgsConstructor
public class MasterAuthController {

    private final MasterAuthService masterAuthService;

    @PostMapping("/login")
    public ResponseEntity<DatosRespuestaMaster> login(@RequestBody DatosLoginMaster datos) {
        return ResponseEntity.ok(masterAuthService.login(datos));
    }

    @GetMapping("/me")
    public ResponseEntity<DatosUsuarioMaster> me(HttpServletRequest request) {
        String userId = (String) request.getAttribute("idUsuario");
        return ResponseEntity.ok(masterAuthService.obtenerUsuario(userId));
    }
}
