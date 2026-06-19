package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.auth.dto.DatosRegistroAuth;
import com.jmcsoft.taco_os.domain.auth.dto.DatosRespuestaAuth;
import com.jmcsoft.taco_os.services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @GetMapping("/verificar/{idGoogle}")
    public ResponseEntity<?> verificarUsuario(@PathVariable String idGoogle) {
        var respuesta = authService.verificarUsuario(idGoogle);

        if (!respuesta.existe()) {
            return ResponseEntity.status(404).body(respuesta);
        }

        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/registrar")
    public ResponseEntity<DatosRespuestaAuth> registrar(@RequestBody DatosRegistroAuth datos) {
        var respuesta = authService.registrar(datos);
        return ResponseEntity.status(201).body(respuesta);
    }
}
