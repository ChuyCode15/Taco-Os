package com.makingcode.taco_os.service;

import com.makingcode.taco_os.config.JwtUtil;
import com.makingcode.taco_os.domain.User;
import com.makingcode.taco_os.dto.AssignRoleRequest;
import com.makingcode.taco_os.dto.AssignRoleResponse;
import com.makingcode.taco_os.dto.LoginRequest;
import com.makingcode.taco_os.dto.LoginResponse;
import com.makingcode.taco_os.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final LicenseService licenseService;

    public LoginResponse login(LoginRequest request) {
        String email = verifyGoogleToken(request.getGoogleToken());
        Optional<User> existing = userRepository.findByEmail(email);

        User user = existing.orElseGet(() -> createUserFromGoogle(email));

        String jwt = jwtUtil.generateToken(user.getId(), user.getEmail());

        LoginResponse response = new LoginResponse();
        response.setJwt(jwt);

        LoginResponse.UserInfo info = new LoginResponse.UserInfo();
        info.setId(user.getId());
        info.setName(user.getName());
        info.setEmail(user.getEmail());
        info.setRole(user.getRole() != null ? user.getRole().name() : null);
        info.setHasBusiness(user.getBusinessId() != null);
        response.setUser(info);

        return response;
    }

    public AssignRoleResponse assignRole(UUID userId, AssignRoleRequest request) {
        User user = userRepository.findById(userId).orElseThrow();
        AssignRoleResponse response = new AssignRoleResponse();

        if ("owner".equals(request.getRole())) {
            user.setRole(User.Role.owner);
            userRepository.save(user);
            response.setRedirectTo("dashboard_owner");
            response.setBusinessId(null);
        } else if ("cashier".equals(request.getRole())) {
            String code = request.getBusinessCode();
            if (code == null || code.isBlank()) {
                response.setError("Se requiere el código del negocio para enlazarse como cajero.");
                return response;
            }
            UUID businessId = decodeBusinessCode(code);
            if (businessId == null) {
                response.setError("Código de negocio inválido.");
                return response;
            }

            var limitError = licenseService.validateCashierLimit(businessId);
            if (limitError != null) {
                response.setError(limitError.getMessage());
                return response;
            }

            user.setRole(User.Role.cashier);
            user.setBusinessId(businessId);
            userRepository.save(user);
            response.setRedirectTo("pantalla_venta");
            response.setBusinessId(businessId);
        }

        return response;
    }

    private String verifyGoogleToken(String googleToken) {
        return "simulado-" + googleToken + "@email.com";
    }

    private User createUserFromGoogle(String email) {
        User user = new User();
        user.setEmail(email);
        user.setName(email.split("@")[0]);
        user.setGoogleId("google_" + email);
        return userRepository.save(user);
    }

    private UUID decodeBusinessCode(String code) {
        try {
            return UUID.fromString(code);
        } catch (Exception e) {
            return null;
        }
    }
}
