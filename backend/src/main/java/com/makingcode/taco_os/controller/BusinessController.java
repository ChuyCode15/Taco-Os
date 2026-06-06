package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.config.JwtUtil;
import com.makingcode.taco_os.dto.CreateBusinessRequest;
import com.makingcode.taco_os.service.BusinessService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/business")
@RequiredArgsConstructor
public class BusinessController {

    private final BusinessService businessService;
    private final JwtUtil jwtUtil;

    @PostMapping
    public ResponseEntity<Object> createBusiness(
            HttpServletRequest request,
            @RequestBody CreateBusinessRequest body) {
        String authHeader = request.getHeader("Authorization");
        String token = authHeader.replace("Bearer ", "");
        UUID userId = jwtUtil.getUserIdFromToken(token);
        return ResponseEntity.ok(businessService.createBusiness(userId, body));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getBusiness(@PathVariable UUID id) {
        return ResponseEntity.ok(businessService.getBusiness(id));
    }
}
