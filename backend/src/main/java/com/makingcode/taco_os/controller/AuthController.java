package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.config.JwtUtil;
import com.makingcode.taco_os.dto.AssignRoleRequest;
import com.makingcode.taco_os.dto.AssignRoleResponse;
import com.makingcode.taco_os.dto.LoginRequest;
import com.makingcode.taco_os.dto.LoginResponse;
import com.makingcode.taco_os.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PutMapping("/role")
    public ResponseEntity<AssignRoleResponse> assignRole(
            HttpServletRequest request,
            @RequestBody AssignRoleRequest roleRequest) {
        String authHeader = request.getHeader("Authorization");
        String token = authHeader.replace("Bearer ", "");
        var userId = jwtUtil.getUserIdFromToken(token);
        return ResponseEntity.ok(authService.assignRole(userId, roleRequest));
    }
}
